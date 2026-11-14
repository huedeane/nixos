{
  lib,
  pkgs,
  username,
  ...
}:

# GPU passthrough for the dual-boot Windows install.
#
# Boot entries (GRUB):
#   "NixOS - Default"  both GPUs on the host as usual, no Windows VM defined
#   "NixOS - iGPU"     host on the 5700G iGPU, RX 6800 XT + 75% CPU/RAM to the VM
#
# One-time setup: run `sudo windows-vm-setup` to build the VM's own EFI disk.

let
  # RX 6800 XT (03:00.0) and its HDMI/DP audio (03:00.1), each in their own IOMMU group
  dgpuIds = [
    "1002:73bf"
    "1002:ab28"
  ];

  # With the BIOS initial output on PCIe1 the iGPU (0c:00.0) has no ROM BAR and amdgpu
  # falls back to a broken "platform" VBIOS (no connectors). Hand it the good image,
  # dumped once in IGD-primary mode, as an ACPI VFCT table, which amdgpu checks first.
  # The kernel's initrd table upgrade rejects VFCT, so GRUB's `acpi` command adds it.
  vbios = ./vbios/cezanne-vbios.rom;
  vfct = pkgs.runCommand "cezanne-vfct.aml" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 - ${vbios} $out <<'EOF'
    import struct, sys
    rom = open(sys.argv[1], "rb").read()
    # GOP_VBIOS_CONTENT: bus, device, function, vendor, device, ssvid, ssid, revision, length
    image = struct.pack("<IIIHHHHII", 0x0C, 0, 0, 0x1002, 0x1638, 0x1458, 0xD000, 0, len(rom)) + rom
    # UEFI_ACPI_VFCT: uuid, VBIOSImageOffset, Lib1ImageOffset, reserved[4]
    body = bytes(16) + struct.pack("<II16x", 76, 0) + image
    length = 36 + len(body)
    header = struct.pack("<4sIBB6s8sI4sI", b"VFCT", length, 1, 0, b"NIXOS ", b"CEZANNE ", 1, b"NIXO", 1)
    table = bytearray(header + body)
    table[9] = (-sum(table)) & 0xFF
    open(sys.argv[2], "wb").write(table)
    EOF
  '';

  domain = "windows";

  # A KVM switch has both its outputs plugged in here; whatever sits behind its second
  # output (the VM side) is attached to the running VM, and released again when switched back.
  kvmPorts = [
    "3-4.4" # USB 2
    "4-4.4" # USB 3
  ];
  kvm-usb = pkgs.writeShellApplication {
    name = "kvm-usb";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      libvirt
    ];
    text = ''
      hostdev() {
        tmp=$(mktemp)
        echo "<hostdev mode='subsystem' type='usb'><source><address bus='$((10#$1))' device='$((10#$2))'/></source></hostdev>" >"$tmp"
        virsh "$3" ${domain} "$tmp" --live || true
        rm -f "$tmp"
      }

      virsh domstate ${domain} 2>/dev/null | grep -q running || exit 0
      case $1 in
        add) hostdev "$2" "$3" attach-device ;;
        remove) hostdev "$2" "$3" detach-device ;;
        attach-all)
          for dev in ${lib.concatMapStringsSep " " (p: "/sys/bus/usb/devices/${p}.*") kvmPorts}; do
            [ -e "$dev/devnum" ] && [ "$(cat "$dev/bDeviceClass")" != 09 ] || continue
            hostdev "$(cat "$dev/busnum")" "$(cat "$dev/devnum")" attach-device
          done
          ;;
      esac
    '';
  };
  kvmRun = action: "RUN+=\"${pkgs.systemd}/bin/systemd-run --no-block ${lib.getExe kvm-usb} ${action} $env{BUSNUM} $env{DEVNUM}\"";
  kvmMatch = ''SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", KERNEL=="${
    lib.concatMapStringsSep "|" (p: "${p}.*") kvmPorts
  }"'';

  espImage = "/var/lib/libvirt/images/windows-esp.img";

  # Windows' bootloader lives on the host's /boot ESP, which must never be shared with
  # the VM. Copy it onto a small private ESP image instead; the BCD points at the
  # Windows partition by disk/partition GUID, which stays the same under passthrough.
  # {bootmgr} also points at the ESP itself by GUID, so the image reuses the host
  # ESP's disk/partition GUIDs (the VM never sees the real NVMe, so they can't clash).
  windows-vm-setup = pkgs.writeShellApplication {
    name = "windows-vm-setup";
    runtimeInputs = with pkgs; [
      coreutils
      util-linux
      dosfstools
      mtools
    ];
    text = ''
      img=${espImage}
      if [ -e "$img" ]; then
        echo "$img already exists, remove it first to rebuild" >&2
        exit 1
      fi
      if [ ! -f /boot/EFI/Microsoft/Boot/bootmgfw.efi ]; then
        echo "no Windows bootloader at /boot/EFI/Microsoft/Boot" >&2
        exit 1
      fi

      esp=$(findmnt -no SOURCE /boot)
      disk_uuid=$(lsblk -dno PTUUID "/dev/$(lsblk -no PKNAME "$esp")")
      part_uuid=$(lsblk -no PARTUUID "$esp")

      tmp=$(mktemp -d)
      trap 'rm -rf "$tmp"' EXIT

      mkfs.fat -F 32 -n ESP -C "$tmp/part" 262144
      mmd -i "$tmp/part" ::/EFI ::/EFI/Boot
      mcopy -s -i "$tmp/part" /boot/EFI/Microsoft ::/EFI/
      mcopy -i "$tmp/part" /boot/EFI/Microsoft/Boot/bootmgfw.efi ::/EFI/Boot/bootx64.efi

      mkdir -p "$(dirname "$img")"
      truncate -s 258M "$tmp/disk"
      printf 'label: gpt\nlabel-id: %s\nstart=2048, size=524288, type=uefi, uuid=%s, name="EFI"\n' \
        "$disk_uuid" "$part_uuid" | sfdisk -q "$tmp/disk"
      dd if="$tmp/part" of="$tmp/disk" bs=1M seek=1 conv=notrunc status=none
      mv "$tmp/disk" "$img"
      echo "created $img"
    '';
  };
in
{
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
  ];

  # install-grub only reads these from the top-level config, so gate on the entry title
  boot.loader.grub = {
    extraFiles."cezanne-vfct.aml" = vfct;
    extraPerEntryConfig = ''if regexp "iGPU" "$chosen"; then acpi ($drive1)/cezanne-vfct.aml; fi'';
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;

  users.users.${username}.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  environment.systemPackages = [ windows-vm-setup ];

  # Keep the domain defined only while the dGPU is on vfio-pci, so it can't be
  # started from the default boot (libvirt would rip the GPU out from under Hyprland).
  systemd.services.windows-vm-define = {
    description = "Define or undefine the Windows passthrough VM";
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.libvirt ];
    script = lib.mkDefault ''
      if virsh dominfo ${domain} >/dev/null 2>&1; then
        virsh undefine ${domain} --keep-nvram --keep-tpm
      fi
    '';
  };

  specialisation.igpu.configuration = {
    system.nixos.tags = [ "igpu" ];
    # install-grub gives specialisation entries no --class (so no theme icon) and pastes
    # this name verbatim into `menuentry "<name>"`, so close the quote to slip one in
    boot.loader.grub.configurationName = ''iGPU (RX 6800 XT to Windows VM)" --class "nixos'';

    # nh rebuilds from inside a specialisation by running *its* switch-to-configuration,
    # which would make this the default GRUB entry and drop the specialisation entries.
    # Always install the bootloader from the full system profile instead.
    system.build.installBootLoader = lib.mkForce (
      pkgs.writeShellScript "install-parent-bootloader" ''
        exec /nix/var/nix/profiles/system/bin/switch-to-configuration boot
      ''
    );

    # Bind the dGPU to vfio-pci before amdgpu/snd_hda_intel can claim it
    boot.initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    boot.kernelParams = [ "vfio-pci.ids=${lib.concatStringsSep "," dgpuIds}" ];
    boot.extraModprobeConfig = "softdep amdgpu pre: vfio-pci";

    services.udev.extraRules = ''
      ACTION=="add", ${kvmMatch}, ATTR{bDeviceClass}!="09", ${kvmRun "add"}
      ACTION=="remove", ${kvmMatch}, ${kvmRun "remove"}
    '';

    # Devices already behind the VM side at boot; libvirt hooks can't call virsh inline
    virtualisation.libvirtd.hooks.qemu.kvm-usb = pkgs.writeShellScript "kvm-usb-hook" ''
      if [ "$1" = ${domain} ] && [ "$2" = started ]; then
        ${pkgs.systemd}/bin/systemd-run --no-block ${lib.getExe kvm-usb} attach-all
      fi
    '';

    systemd.services.windows-vm-define.script = ''
      virsh net-autostart default
      virsh net-info default | grep -q 'Active: *yes' || virsh net-start default
      virsh define ${pkgs.replaceVars ./windows-vm.xml { gpuRom = ./vbios/rx6800xt-vbios.rom; }}
    '';
  };
}

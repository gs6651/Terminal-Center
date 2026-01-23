
# Tips n Tricks

## Dual Setup (Windows - Feodra)

- Prepare Windows bootable pendrive using `woeusb`, recommended.
- If you're on linux, use commands:

```bash
sudo apt update
sudo apt add ppa:
```

- Disable Fastboot

## Repair Windows

- **Step 1: Remove the Linux Partitions in Windows**

  - Boot into Windows.
  - Open Disk Management by typing `diskmgmt.msc` in the Run dialog (Windows key + R).
  - Identify the Linux partitions, which will be unlabeled or have different file systems (e.g., ext4).
  - Right-click: on each identified Linux partition and select "Delete Volume".
  - Confirm the deletions to turn the Linux partitions into unallocated space.

- **Step 2: Repair the Windows Bootloader using a Recovery Drive**

  - Create a Windows recovery drive: or use your installation media.
  - Boot your computer: from the recovery drive or installation media.
  - Select the option to "Repair your computer".
  - Navigate to Troubleshoot > Advanced options > Command Prompt.
  - In the Command Prompt, type the following commands, pressing Enter after each one:
    - `bootrec /fixmbr`,
    - `bootrec /fixboot`
    - `bootrec /scanos`
    - `bootrec /rebuildbcd`
  - If prompted to add the Windows installation to the boot list, type Y or A and press Enter.
  - Type `exit` to close the command prompt and restart your computer normally.

- **Step 3: Clean the EFI Partition (if necessary)**

If you still see the GRUB boot menu, you may need to clean the EFI partition. Follow below steps:

- From within Windows, open a Command Prompt as an administrator.
- Use diskpart to find and assign a letter to the EFI partition:
  - `diskpart`
  - `list disk`
  - `sel disk X` (where X is your boot drive)
  - `list vol`
  - `sel vol Y` (where Y is the EFI/System partition)
  - `assign letter=Z:` (use an unused letter)
  - `exit`
- avigate to the EFI partition in the Command Prompt: Z:.
- Delete the Linux boot folder (e.g., 'ubuntu', 'obuvuntu', or the name of your distro):
- `cd EFI`
- `rmdir /S <linux-distro-folder-name>`

Restart your computer to confirm that it now boots directly into Windows.

## Shorten PowerShell Path

- Run `Test-Path $Profile` to check if a profile file exists.
- If it returns `False`, create a profile file using `New-Item –Path $Profile –Type File –Force`.
- **Note: This will create the profile file or overwrite the existing one.
- Open the profile file using `notepad $Profile`
- Add the following function to the file and save

```shell
function prompt {
        "PS " + (Get-Location).Drive.Name + ":\" + $( ( Get-Item $pwd ).Name ) + ">"
}
```

- Reopen PowerShell (or VS Code Terminal)
- ✌️

## Starship for PowerShell

- [Website](https://starship.rs/guide/)
- Download Fira Code. [URL](https://www.nerdfonts.com/)
- Install Starship
  - `winget install --id Starship.Starship`
- Set up your shell to use Starship
  - Add the following to the end of your PowerShell configuration (find it by running $PROFILE)
    - `Invoke-Expression (&starship init powershell)`

flavor = "vm.alaska.cpu.general.small"
networks = ["a262aabd-e6bf-4440-a155-13dbc1b5db0e"] # WCDC-iLab-60
source_image_name = "RockyLinux-8.5-20211114.2"
ssh_keypair_name = "slurm-app-ci"
security_groups = ["default", "SSH"]
ssh_bastion_host = "128.232.222.183"
ssh_bastion_username = "slurm-app-ci"
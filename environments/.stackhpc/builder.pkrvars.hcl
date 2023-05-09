flavor = "vm.ska.cpu.general.small"
networks = ["a262aabd-e6bf-4440-a155-13dbc1b5db0e"] # WCDC-iLab-60
source_image_name = "openhpc-230503-0944-bf8c3f63.qcow2" # https://github.com/stackhpc/ansible-slurm-appliance/pull/252
fatimage_source_image_name = "Rocky-8-GenericCloud-8.6.20220702.0.x86_64.qcow2"
ssh_keypair_name = "slurm-app-ci"
security_groups = ["default", "SSH"]
ssh_bastion_host = "128.232.222.183"
ssh_bastion_username = "slurm-app-ci"
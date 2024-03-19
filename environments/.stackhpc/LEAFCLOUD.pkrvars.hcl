flavor = "en1.xsmall"
use_blockstorage_volume = true
volume_size = 12 # GB. Compatible with SMS-lab's general.v1.tiny
volume_type = "unencrypted"
image_disk_format = "qcow2"
networks = ["909e49e8-6911-473a-bf88-0495ca63853c"] # slurmapp-ci
ssh_keypair_name = "slurm-app-ci"
ssh_private_key_file = "~/.ssh/id_rsa"
security_groups = ["default", "SSH"]
floating_ip_network = "external"

data "openstack_images_image_v2" "control" {
  name = var.control_node.image
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "user-data"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/control.userdata.tpl",
                                {
                                  state_dir = var.state_dir
                                }
                              )
  }
}

resource "openstack_networking_port_v2" "login" {
  for_each = toset(keys(var.login_nodes))

  name = "${var.cluster_name}-${each.key}"
  network_id = data.openstack_networking_network_v2.cluster_net.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.cluster_subnet.id
  }

  security_group_ids = [for o in data.openstack_networking_secgroup_v2.login: o.id]

  binding {
    vnic_type = var.vnic_type
    profile = var.vnic_profile
  }
}

resource "openstack_networking_port_v2" "nonlogin" {
  for_each = toset(concat(["control"], keys(var.compute_nodes)))

  name = "${var.cluster_name}-${each.key}"
  network_id = data.openstack_networking_network_v2.cluster_net.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.cluster_subnet.id
  }

  security_group_ids = [for o in data.openstack_networking_secgroup_v2.nonlogin: o.id]

  binding {
    vnic_type = var.vnic_type
    profile = var.vnic_profile
  }
}


resource "openstack_compute_instance_v2" "control" {
  
  name = "${var.cluster_name}-control"
  image_name = data.openstack_images_image_v2.control.name
  flavor_name = var.control_node.flavor
  key_pair = var.key_pair
  # root device:
  block_device {
      uuid = data.openstack_images_image_v2.control.id
      source_type  = "image"
      destination_type = "local"
      boot_index = 0
      delete_on_termination = true
  }

  # state volume:
  block_device {
      destination_type = "volume"
      source_type  = "volume"
      boot_index = -1
      uuid = openstack_blockstorage_volume_v3.state.id
  }

  # home volume:
  block_device {
      destination_type = "volume"
      source_type  = "volume"
      boot_index = -1
      uuid = openstack_blockstorage_volume_v3.home.id
  }

  network {
    port = openstack_networking_port_v2.nonlogin["control"].id
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

  user_data = data.template_cloudinit_config.config.rendered

}

resource "openstack_compute_instance_v2" "login" {

  for_each = var.login_nodes
  
  name = "${var.cluster_name}-${each.key}"
  image_name = each.value.image
  flavor_name = each.value.flavor
  key_pair = var.key_pair
  
  network {
    port = openstack_networking_port_v2.login[each.key].id
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

}

resource "openstack_compute_instance_v2" "compute" {

  for_each = var.compute_nodes
  
  name = "${var.cluster_name}-${each.key}"
  image_name = lookup(var.compute_images, each.key, var.compute_types[each.value].image)
  flavor_name = var.compute_types[each.value].flavor
  key_pair = var.key_pair
  
  network {
    port = openstack_networking_port_v2.nonlogin[each.key].id
    access_network = true
  }

  metadata = {
    environment_root = var.environment_root
  }

}

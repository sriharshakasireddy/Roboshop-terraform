
module "components" {

  for_each = var.components
 source = "./Modules/vm"
  component = each.value["name"]
 vm_size   = each.value["vm_size"]
 env = var.env


}






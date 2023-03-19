# # Distributed firewall
# resource "aviatrix_distributed_firewalling_policy_list" "demo" {
#   policies {
#     name     = "Allow-edge-sv-to-aws"
#     action   = "PERMIT"
#     priority = 30
#     protocol = "Any"
#     logging  = true
#     watch    = false
#     src_smart_groups = [
#       aviatrix_smart_group.edge_sv.uuid
#     ]
#     dst_smart_groups = [
#       aviatrix_smart_group.aws.uuid
#     ]
#   }
#   policies {
#     name     = "Allow-edge-dc-to-aws"
#     action   = "PERMIT"
#     priority = 40
#     protocol = "Any"
#     logging  = true
#     watch    = false
#     src_smart_groups = [
#       aviatrix_smart_group.edge_dc.uuid
#     ]
#     dst_smart_groups = [
#       aviatrix_smart_group.aws.uuid,
#     ]
#   }
#   policies {
#     name     = "Application-deny-all"
#     action   = "DENY"
#     priority = 1000
#     protocol = "Any"
#     logging  = true
#     watch    = false
#     src_smart_groups = [
#       aviatrix_smart_group.landing_zone.uuid,
#       aviatrix_smart_group.edge_sv.uuid,
#       aviatrix_smart_group.edge_dc.uuid,
#       aviatrix_smart_group.aws.uuid
#     ]
#     dst_smart_groups = [
#       aviatrix_smart_group.landing_zone.uuid,
#       aviatrix_smart_group.edge_sv.uuid,
#       aviatrix_smart_group.edge_dc.uuid,
#       aviatrix_smart_group.aws.uuid
#     ]
#   }
#   policies {
#     name     = "DefaultAllowAll"
#     action   = "PERMIT"
#     priority = 2147483647
#     protocol = "Any"
#     logging  = true
#     watch    = false
#     src_smart_groups = [
#       "def000ad-0000-0000-0000-000000000000"
#     ]
#     dst_smart_groups = [
#       "def000ad-0000-0000-0000-000000000000"
#     ]
#   }
# }

# # Network segmentation
# resource "aviatrix_segmentation_network_domain" "demo" {
#   for_each    = toset(local.network_domains)
#   domain_name = each.value
# }

# # resource "aviatrix_segmentation_network_domain_association" "aws" {
# #   network_domain_name = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
# #   attachment_name     = module.avx_spoke.spoke_gateway.gw_name
# # }

# # resource "aviatrix_segmentation_network_domain_association" "landing_zone" {
# #   network_domain_name = aviatrix_segmentation_network_domain.demo["Landing_zone"].domain_name
# #   attachment_name     = module.avx_landing_zone.spoke_gateway.gw_name
# # }

# # # TODO calculate from edge module
# # resource "aviatrix_segmentation_network_domain_association" "edge_sv" {
# #   network_domain_name = aviatrix_segmentation_network_domain.demo["Edge"].domain_name
# #   attachment_name     = "sv-metro-equinix-edge-1"
# # }

# # # TODO calculate from edge module
# # resource "aviatrix_segmentation_network_domain_association" "edge_dc" {
# #   network_domain_name = aviatrix_segmentation_network_domain.demo["Edge"].domain_name
# #   attachment_name     = "dc-metro-equinix-edge-1"
# # }

# # resource "aviatrix_segmentation_network_domain_connection_policy" "aws_edge" {
# #   domain_name_1 = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
# #   domain_name_2 = aviatrix_segmentation_network_domain.demo["Edge"].domain_name
# # }

# # resource "aviatrix_segmentation_network_domain_connection_policy" "aws_landing_zone" {
# #   domain_name_1 = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
# #   domain_name_2 = aviatrix_segmentation_network_domain.demo["Landing_zone"].domain_name
# # }
# Distributed firewall
resource "aviatrix_distributed_firewalling_policy_list" "demo" {
  policies {
    name     = "Allow-edge-sv-to-aws"
    action   = "PERMIT"
    priority = 30
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.edge_sv.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.aws.uuid
    ]
  }
  policies {
    name     = "Allow-edge-dc-to-aws"
    action   = "PERMIT"
    priority = 40
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.edge_dc.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.aws.uuid,
    ]
  }
  policies {
    name     = "Allow-edge-sv-to-azure"
    action   = "PERMIT"
    priority = 50
    protocol = "Any"
    logging  = true
    watch    = true
    src_smart_groups = [
      aviatrix_smart_group.edge_sv.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.aws.uuid
    ]
  }
  policies {
    name     = "Allow-edge-dc-to-azure"
    action   = "PERMIT"
    priority = 60
    protocol = "Any"
    logging  = true
    watch    = true
    src_smart_groups = [
      aviatrix_smart_group.edge_dc.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.aws.uuid,
    ]
  }
  policies {
    name     = "Application-deny-all"
    action   = "DENY"
    priority = 1000
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.landing_zone.uuid,
      aviatrix_smart_group.edge_sv.uuid,
      aviatrix_smart_group.edge_dc.uuid,
      aviatrix_smart_group.aws.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.landing_zone.uuid,
      aviatrix_smart_group.edge_sv.uuid,
      aviatrix_smart_group.edge_dc.uuid,
      aviatrix_smart_group.aws.uuid
    ]
  }
  policies {
    name     = "DefaultAllowAll"
    action   = "PERMIT"
    priority = 2147483647
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      "def000ad-0000-0000-0000-000000000000"
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000000"
    ]
  }
}

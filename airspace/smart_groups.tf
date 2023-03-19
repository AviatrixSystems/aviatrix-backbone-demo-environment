resource "aviatrix_smart_group" "edge_sv" {
  name = "Edge_Silicon_Valley"
  selector {
    match_expressions {
      cidr = "10.40.0.0/16"
    }
  }
}

resource "aviatrix_smart_group" "edge_dc" {
  name = "Edge_Washington"
  selector {
    match_expressions {
      cidr = "10.50.0.0/16"
    }
  }
}

resource "aviatrix_smart_group" "aws" {
  name = "Aws"
  selector {
    match_expressions {
      cidr = "10.6.2.0/24"
    }
  }
}

resource "aviatrix_smart_group" "landing_zone" {
  name = "Landing_Zone"
  selector {
    match_expressions {
      cidr = "10.7.2.0/24"
    }
  }
}

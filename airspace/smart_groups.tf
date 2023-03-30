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
      cidr = local.cidrs.aws_us_east_1
    }
    match_expressions {
      cidr = local.cidrs.aws_us_east_2
    }
    match_expressions {
      cidr = local.cidrs.avx_us_east_2
    }
  }
}

resource "aviatrix_smart_group" "aws_dev" {
  name = "Aws_dev"
  selector {
    match_expressions {
      cidr = local.cidrs.aws_us_east_1_dev
    }
    match_expressions {
      cidr = local.cidrs.aws_us_east_2_dev
    }
  }
}

resource "aviatrix_smart_group" "landing_zone" {
  name = "Landing_Zone"
  selector {
    match_expressions {
      cidr = local.cidrs.aws_us_east_1_landing
    }
  }
}

ec2_vpc{ 'WebServersVPC':
ensure  => present,
region => 'us-east-1',
instance_tenancy => 'default',
cidr_block => '20.0.0.0/16',
}
ec2_vpc_subnet { 'WebServersSubnet' :
ensure => present,
vpc => 'WebServersVPC',
region => 'us-east-1',
availability_zone   => 'us-east-1a',
cidr_block => '20.0.0.0/24',
route_table => 'WebServersRoute',
}
ec2_vpc_internet_gateway{ 'WebServersIGW' :
ensure => present,
region => 'us-east-1',
vpc => 'WebServersVPC',
}
ec2_vpc_routetable{ 'WebServersRoute':
ensure => present,
region => 'us-east-1',
vpc => 'WebServersVPC',
routes => [
    {
      destination_cidr_block => '20.0.0.0/16',
      gateway                => 'local'
    },{
      destination_cidr_block => '0.0.0.0/0',
      gateway                => 'WebServersIGW'
    },
  ],
}  
ec2_securitygroup { 'DevOpsWebServerSecurity':
  ensure      => present,
  region      => 'us-east-1',
  description => 'InstanceLevelSecurity',
  subnet      => 'WebServersSubnet',
  vpc         => 'WebServersVPC',
  ingress     => [{
    protocol  => 'tcp',
    port      => 80,
    cidr      => '0.0.0.0/0',
#  },{
#    security_group => 'other-security-group',
  }],
#  tags        => {
#    tag_name  => 'value',
#  },
}
ec2_instance { 'WebServer1':
  ensure            => present,
  region            => 'us-east-1',
  availability_zone => 'us-east-1a',
  image_id          => 'ami-2d39803a',
  instance_type     => 't2.micro',
  monitoring        => true,
  key_name          => 'sample',
  subnet 			=> 'WebServersSubnet',
  security_groups   => ['DevOpsWebServerSecurity'],
  user_data         => template('apache-puppet.sh'),
#  tags              => {
#    tag_name => 'value',
#  },
}
ec2_instance { 'WebServer2':
  ensure            => present,
  region            => 'us-east-1',
  availability_zone => 'us-east-1b',
  image_id          => 'ami-2d39803a',
  instance_type     => 't2.micro',
  monitoring        => true,
  key_name          => 'sample',
  subnet 			=> 'WebServersSubnet',
  security_groups   => ['DevOpsWebServerSecurity'],
  user_data         => template('apache-puppet.sh'),
#  tags              => {
#    tag_name => 'value',
#  },
}

elb_loadbalancer { 'WebServerLB':
  ensure               => present,
  region               => 'us-east-1',
  availability_zones   => ['us-east-1a', 'us-east-1b'],
  instances            => ['WebServer1', 'WebServer2'],
  security_groups      => ['WebServersSecurity'],
  listeners            => [{
    protocol           => 'HTTP',
    load_balancer_port => 80,
    instance_protocol  => 'HTTP',
    instance_port      => 80,
  },{
    protocol           => 'HTTPS',
    load_balancer_port => 443,
    instance_protocol  => 'HTTPS',
    instance_port      => 8080,
    ssl_certificate_id => 'arn:aws:acm:us-east-1:744910358745:certificate/332e4a7e-e03d-4d2e-876e-79b623601f18',
  }],
  tags                 => {
    tag_name => 'value',
  },
}

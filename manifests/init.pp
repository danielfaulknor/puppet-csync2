# Class: csync2
#
# Main csync2 class.
#
# Sample Usage :
#  include csync2
#
class csync2 (
  $cfg_source  = undef,
  $cfg_content = undef,
  $key_source  = undef,
  $key_content = undef,
  $xinetd      = true,
  # Only used if $xinetd is true
  $port        = '30865',
  $only_from   = '10.0.0.0/8'
  $manage_firewall = undef,
) {

  package { 'csync2': ensure => installed }

  # Optional main configuration and main key files
  if $cfg_source or $cfg_content {
    csync2::cfg { 'MAIN':
      source  => $cfg_source,
      content => $cfg_content,
    }
  } else {
    csync2::cfg { 'MAIN':
      ensure => absent,
    }
  }
  if $key_source or $key_content {
    csync2::key { 'MAIN':
      source  => $key_source,
      content => $key_content,
    }
  } else {
    csync2::key { 'MAIN':
      ensure => absent,
    }
  }

  # Manage Firewall
  if $manage_firewall == true {
    firewall { '001 Allow csync2':
      dport    => $port,
      proto    => tcp,
      action   => accept,
      source   => $only_from
    }
  }
  
  # Mandatory xinetd service, optionally managed here
  if $xinetd == true {
    xinetd::serviceconf { 'csync2':
      service_type => 'UNLISTED',
      flags        => 'REUSE',
      server       => '/usr/sbin/csync2',
      server_args  => '-i',
      port         => $port,
      only_from    => $only_from,
      require      => Package['csync2'],
    }
  }

}


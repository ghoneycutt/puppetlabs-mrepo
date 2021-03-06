# Class: mrepo::rhn
#
# This class installs dependencies for Redhat Network mirroring.
#
# Parameters:
#   Optional parameters can be found in the mrepo::params class
#
# Actions:
#   Prepares a system to act as a RHN mirror. This primarily handles the
#   specifics of preparing a CentOS host to connect to the RHN.
#
# Sample Usage:
#   This class does not need to be directly included
class mrepo::rhn {

  include mrepo::params
  $group = $mrepo::params::group

  if $mrepo::params::rhn == true {

    package { "pyOpenSSL":
      ensure  => present,
    }

    # CentOS does not have redhat network specific configuration files by default
    if $operatingsystem == 'CentOS' {
      exec { "Generate rhnuuid":
        command => 'printf "rhnuuid=%s\n" `/usr/bin/uuidgen` >> /etc/sysconfig/rhn/up2date-uuid',
        path    => [ "/usr/bin", "/bin" ],
        user    => "root",
        group   => $group,
        creates => "/etc/sysconfig/rhn/up2date-uuid",
        logoutput => on_failure,
      }

      file { "/etc/sysconfig/rhn/up2date-uuid":
        ensure  => present,
        replace => false,
        owner   => "root",
        group   => $group,
        mode    => "0640",
        require => Exec["Generate rhnuuid"],
      }

      file { "/etc/sysconfig/rhn/sources":
        ensure  => present,
        owner   => "root",
        group   => "root",
        mode    => "0644",
        content => "up2date default",
      }

      file { "/usr/share/mrepo/rhn/RHNS-CA-CERT":
        ensure  => present,
        owner   => "root",
        group   => "root",
        mode    => "0644",
        source  => "puppet:///modules/mrepo/RHNS-CA-CERT",
      }
    }
  }
}

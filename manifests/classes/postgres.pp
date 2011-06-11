class postgres {
    if $pgversion == "" {
        exec { '/bin/false # missing postgres version': }
    } else {
        case $operatingsystem {
            "redhat",
            "centos": {
        
                case $pgversion {
                    8.3: {
                        $servicename = 'postgresql-8.3'
                        $servicealias = 'postgresql'
                        $packagename = 'postgresql-$pgversion'
                        $pgdata = "/etc/postgresql/$pgversion/main"
                    }
                    9.0: {
                        include yum::repo::pgdg90
                        $servicename = 'postgresql-9.0'
                        $servicealias = 'postgresql'
                        $packagename = 'postgresql90-server'     
                        $pgdata = '/var/lib/pgsql/9.0/data'
                        file { 'postgresql.sh':
                            mode        => 755,
                            owner       => 'root',
                            group       => 'root',
                            path        => '/etc/profile.d/postgresql.sh',
                            content     => "PATH=\$PATH:/usr/pgsql-9.0/bin",
                        }
         
                    }
                    default: {		    
                        $servicename = 'postgresql'
                        $servicealias = undef
                        $packagename = 'postgresql'
                        $pgdata = "/etc/postgresql/$pgversion/main"
                    }
                }
            }
            default: { 
            }
        }
        
        package { $packagename:
            ensure => installed,
            alias  => 'postgres',
            before => [
                User['postgres'],
                Group['postgres'],
                Service['postgresql'],
                File['pg_hba'],
                File[$pgdata],
                Exec['postgres-initdb'],
            ],
            require => Yumrepo['pgdg90'],
            
        }

        user { 'postgres':
            ensure  => present,
            gid     => postgres,
            require => [
                Group['postgres'],
                Package['postgres'],
            ],
        }

        group { 'postgres':
            ensure  => present,
            require => Package[$packagename],
        }

        file { 'pg_hba':
            mode         => 644,
            owner        => 'postgres',
            group        => 'postgres',
            path         => "$pgdata/pg_hba.conf",
            notify       => Exec['postgres-reload'],
            require      => [
                User['postgres'],
                Group['postgres'],
            ],
        }

        exec { "/etc/init.d/$servicename reload":
            refreshonly => true,
            require     => Service['postgresql'],
            alias       => 'postgres-reload',
        }
        
        file { $pgdata:
            ensure => directory, 
            mode => 0700, 
            owner => 'postgres', 
            require => [
                User['postgres'],
                Group['postgres'],
            ],
        }
        
        exec { "/etc/init.d/$servicename initdb": 
            unless => "test -f $pgdata/PG_VERSION",
            before => File[$pgdata],
            alias  => 'postgres-initdb',
        }

        service { $servicename:
            ensure     => running,
            enable     => true,
            hasstatus  => true,
            hasrestart => true,
            alias      => $servicealias,
            require    => [
                User['postgres'],
                Package['postgres'],
                File[$pgdata],
            ],
        }
    }
}

# vi:syntax=puppet:filetype=puppet:ts=4:et:

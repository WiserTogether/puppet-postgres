class postgres::params {
    if $pgversion == "" {
        $pgversion = 9.0
    }
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
                    require yum::repo::pgdg90
                    $servicename = 'postgresql-9.0'
                    $servicealias = 'postgresql'
                    $packagename = 'postgresql90-server'
                    $pgdata = '/var/lib/pgsql/9.0/data'
                    $pgroot = '/var/lib/pgsql'
                    file { 'postgresql.sh':
                        mode        => 755,
                        path        => '/etc/profile.d/postgresql.sh',
                        content     => "PATH=\$PATH:/usr/pgsql-9.0/bin",
                    }

                }
                default: {
                    $servicename = 'postgresql'
                    $servicealias = 'postgresql'
                    $packagename = 'postgresql'
                    $pgdata = "/etc/postgresql/$pgversion/main"
                }
            }
        }
        "darwin": {
            case $pgversion {
                default: {
                    $servicename = 'com.edb.launchd.postgresql-9.0'
                    $servicealias = 'postgresql'
                    $packagename = 'postgresql-9.0.10-1-osx.dmg'
                    $pgroot = '/Library/PostgreSQL/9.0'
                    $pgdata = '/Library/PostgreSQL/9.0/data'
                }
            }
        }
        default: {
        }
    }
}


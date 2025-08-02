download: 
Download the Presto server tarball, presto-server-0.293.tar.gz - https://prestodb.io/docs/current/installation/deployment.html#installing-presto:~:text=presto%2Dserver%2D0.293.tar.gz

configure
Create an etc directory inside the installation directory. This will hold the following configuration:

Node: 
etc/node.properties, contains configuration specific to each node

    node.environment=production
    node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
    node.data-dir=/var/presto/data

node.environment: The name of the environment. All Presto nodes in a cluster must have the same environment name.

node.id: The unique identifier for this installation of Presto. This must be unique for every node. This identifier should remain consistent across reboots or upgrades of Presto. If running multiple installations of Presto on a single machine (that is, multiple nodes on the same machine), each installation must have a unique identifier.

node.data-dir: The location (filesystem path) of the data directory. Presto will store logs and other data here.

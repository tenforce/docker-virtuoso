# Virtuoso docker
Docker for hosting Virtuoso.

The Virtuoso is built from a specific commit SHA in https://github.com/openlink/virtuoso-opensource.

The Docker image tags include the Virtuoso version installed in the container. The following [versions are currently available](https://hub.docker.com/r/tenforce/virtuoso/tags/):
- 1.0.0-virtuoso7.2.4
- 1.0.0-virtuoso7.2.2
- 1.0.0-virtuoso7.2.1
- 1.0.0-virtuoso7.2.0

## Running your Virtuoso
    docker run --name my-virtuoso \
        -p 8890:8890 -p 1111:1111 \
        -e DBA_PASSWORD=myDbaPassword \
        -e SPARQL_UPDATE=true \
        -e DEFAULT_GRAPH=http://www.example.com/my-graph \
        -v /my/path/to/the/virtuoso/db:/data \
        -d tenforce/virtuoso

The Virtuoso database folder is mounted in `/data`.

The Docker image exposes port 8890 and 1111.

The `dba` password can be set at container start up via the `DBA_PASSWORD` environment variable. If not set, the default `dba` password will be used.

The `SPARQL_UPDATE` permission on the SPARQL endpoint can be granted by setting the `SPARQL_UPDATE` environment variable to `true`.

## Dumping your Virtuoso data as quads
Enter the Virtuoso docker, open ISQL and execute the `dump_nquads` procedure. The dump will be available in `/my/path/to/the/virtuoso/db/dumps`.

    docker exec -it my-virtuoso bash
    isql-v -U dba -P $DBA_PASSWORD
    SQL> dump_nquads ('dumps', 1, 10000000, 1);

For more information, see http://virtuoso.openlinksw.com/dataspace/doc/dav/wiki/Main/VirtRDFDumpNQuad

## Loading quads in Virtuoso
### Manually
Make the quad `.nq` files available in `/my/path/to/the/virtuoso/db/dumps`. The quad files might be compressed. Enter the Virtuoso docker, open ISQL, register and run the load.

    docker exec -it my-virtuoso bash
    isql-v -U dba -P $DBA_PASSWORD
    SQL> ld_dir('dumps', '*.nq', 'http://foo.bar');
    SQL> rdf_loader_run();

Validate the `ll_state` of the load. If `ll_state` is 2, the load completed.
 
    select * from DB.DBA.load_list;

For more information, see http://virtuoso.openlinksw.com/dataspace/doc/dav/wiki/Main/VirtBulkRDFLoader

### Automatically
By default, any data that is put in the `toLoad` directory in the Virtuoso database folder (`/my/path/to/the/virtuoso/db/toLoad`) is automatically loaded into Virtuoso on the first startup of the Docker container. The default graph is set by the DEFAULT_GRAPH environment variable, which defaults to `http://localhost:8890/DAV`.



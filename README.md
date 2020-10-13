# Running the server

To run the server, enter the following command:

`ruby main.rb`

You can now make requests against the server.

# Making requests against the server

Note that only requests prefixed with `/files` will be available for download. The special case of `/` will shortcut to `/files`. Therefore, to make a request against the server, enter something like the following:

`curl http://localhost:2000/files/test.html` or `curl http://localhost:2000`

# Test Output in Parallel

To run multiple requests at once against the server and see that it retrieves the
files as expected, run the following command (requires installing the parallel command):

`sudo apt install parallel`

`parallel -j 4 curl -q {} < testrequests.out`

or run

`parallel -j 4 wget -q {} < testrequests.out'

to have the files saved to the directory.

# Run tests

To run the testsuite, enter the following command:

`rake test`

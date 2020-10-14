# Running the server

To run the server, enter the following command:

`ruby main.rb`

You can now make requests against the server.

# Making requests against the server

Files are served from the files directory, but the user will not know this and will request them using the path within the files directory to the file. The special case of `/` will shortcut to `/index.html`. Therefore, to make a request against the server, enter something like the following:

`curl http://localhost:2000/test.html` or `curl http://localhost:2000`

Both serve the same file located at files/test.html. Open a browser and navigate to any file located in the files directory by appending the relative path from the root directory of this folder without the `files` prefix.

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

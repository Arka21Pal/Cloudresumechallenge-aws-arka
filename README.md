# Cloud resume Challenge (WAS version)

The project was built based on instructions from the website for the [Cloud resume challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/).

I will fashion the effort I put into this project into steps for brevity:
- Create an `s3` bucket.
- Create a `cloudfront` distribution to serve static files from aforementioned `s3` bucket.
- Write configuration for the `dynamoDB` table to store a value (number of visits to website).
    - A "Composite key" is what `dynamoDB` needs to index the data. Technically, one could do without this, but this was the easiest option, as there would be other complications in using a single key which I did not explore.
    - The composite key is formed from the `HASH` and `RANGE` keys.
    - In my case, the data type indexed by either key was an integer, but one can change that.
- Create `python` script to "interface" with the table (using the `boto3` library).
    - The response from the script is very important for the forthcoming API, as I will mention in a subsequent point.
- Configure `lambda` function to utilise the script.
    - Every `lambda` instance passes the variables `event` and `context` to the function running inside it. I had to make sure that my function, at the least, accepted the two variables (even though I didn't get around to using them).
    - For the `lambda` to actually run this code, it needs to be able to access it, and basically read it.
        - If one has some simple code, `zip` is a good option.
        - But that wouldn't work in my case, so I had to configure an `s3` bucket, along with the requisite permissions for the `lambda` function to access the file inside the bucket and read from that.
- Write configuration for API Gateway to utilise mentioned `lambda` function and get the value from the database table.
    - Without the correct response with the right parameters (this was an HTTP API so required some specific headers in the response, probably different for REST APIs), the output would be `NULL`/`None`.
- The next problem I faced was: to call the API, I would need to know the URL.
    - The problem being that AWS assigns an unique ID/combination of characters to the API when it is created.
    - Thus, I needed a way to scrape the API URL and then invoke it.
- Thus, create another `lambda` function with more code, this time to list APIs in an account (the credentials were served using environment variables, which are destroyed when the `lambda` instance is decommissioned).
    - This `lambda` function would then write the API URL to a file.
    - Then, this API would be called using the API from the file.
    - Of course, this necessitated the need for another file and more permissions.
- The Shell scripts utilised should work on POSIX systems (inasmuch assuming that Debian's Dash can be trusted to maintain compatibility).
    - The first shell script `s3run.sh` invokes the cloudformation template for the storage bucket (holds the code for both `lambda` functions).
    - The second script, `run.sh` invokes the main template, `template.yaml`, creates the entire infrastructure (other than that of the `storage-bucket`, which was done by `s3run.sh`).
        - It then uploads the static website files, creates `lambda` environment variables.
        - The various flags that can be used with this script enable it to both deploy and delete the main template, both of which call the correct, related flag of the template `s3run.sh` from itself.
    - Both scripts have a "help" function to list their capabilities.

---

I have used *many* resources from around the web for this project, this is a great resource if anyone wants a reference for the project (note that the author uses `SAM` whilst I have exclusively stuck with `cloudformation`):
- Video series refererred to here: https://www.youtube.com/playlist?list=PLEk97Q5Nj5oesA1WNk7DzaUpZUnCsQFVQ
    - Github link for `^`: https://github.com/openupthecloud/cloud-resume-challenge

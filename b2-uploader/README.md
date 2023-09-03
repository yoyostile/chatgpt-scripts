# Backblaze B2 Recursive Uploader 🚀

A Bash script for recursively uploading files and directories to a Backblaze B2 bucket.

## Requirements 🛠️

- Bash
- `curl`
- `jq`
- `sha1sum`

## Environment Variables 🔑

Before running the script, set the following environment variables:

- `B2_BUCKET_ID`: Your Backblaze B2 Bucket ID
- `B2_ACCOUNT_ID`: Your Backblaze B2 Account ID
- `B2_ACCOUNT_KEY`: Your Backblaze B2 Account Key

You can set them like so:

```bash
export B2_BUCKET_ID="your_bucket_id"
export B2_ACCOUNT_ID="your_account_id"
export B2_ACCOUNT_KEY="your_account_key"
```

## Usage 🚀

Run the script and pass either a file or directory as the first argument.

```bash
./upload.sh /path/to/file_or_directory
```

That's it! Your files will be uploaded to Backblaze B2. 🎉

# Helm - NOTES.txt File

## What is NOTES.txt file?

At the end of a `helm install` or `helm upgrade`, Helm can print out a block of helpful information for users.

As the author of a chart, you can add any post-install information via the `NOTES.txt` file, which is print out as the `NOTES` field.

> [!INFO]
> Although being a plaintext file, `NOTES.txt` is treated as a template.
>
> All template function, objects are available.

e.g.

- A basic NOTES.txt file
  
  ```
  Thank you for installing {{ .Chart.Name }}.
  
  Your release is named {{ .Release.Name }}.
  
  To learn more about the release, try:
  
    $ helm status {{ .Release.Name }}
    $ helm get all {{ .Release.Name }}
  ```

## Why there is NOTES.txt file?

NOTES.txt is used to send post-installation instructions to the users of your chart.


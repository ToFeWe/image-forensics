# image-forensics

An integrated framework for image forensic analysis as a web service. This framework implements a number of well-established image tampering localization algorithms, plus a number of tools for image metadata extraction and visualization, including GPS localization and the display of embedded thumbnail(s). It includes an API for downloading an image from the web, extracting an integrated forensics report for an image, storing it in a MongoDB collection under a unique hash identifier and returning it upon request.

## Getting started

The library requires Java 8 and MogoDB installed in order to operate. The main API is located in class `main.java.api.ReportManagement` and consists of three methods:

* downloadURL
* createReport
* getReport

The first takes as input a URL, downloads the corresponding image and creates an empty database entry with the corresponding hash. The second takes as input a hash, and populates the corresponding database entry with the analysis results. The third method can be called at any time, takes a hash as input, and returns the contents of the corresponding database entry at the time, in the form of a ForensicReport object.


## Downloading an image from a URL

The method requires the image URL (can also be a local `file:/`), the path to an output folder where the image will be stored, and the IP of the MongoDB server:

    `String hash = downloadURL("http://some.domain/some_image.jpg", "/home/myhome/DownloadedPics/", "127.0.0.1")`

Upon completion, the method returns a string containing the hash of the URL, if the image was downloaded correctly, or the string `"URL_ERROR"` if the URL could not be downloaded. If the process completed successfully, a MongoDB entry is also created, using the Hash as key.

## Building a forensics report

Consecutively, the `createReport` method can be called, in order to populate the report with the output of the various algorithms and features. It requires the hash, the IP of the MongoDB server and the output folder where the images produced by the tampering localization algorithms will be stored:

    `createReport(hash, "127.0.0.1", "/home/myhome/DownloadedPics/");`

The framework has been written with the aim of being wrapped with a Web service, and thus attention has been paid to maximizing asynchronous operations. To this end, the various operations called by `createReport()` operate asynchronously, with each method updating the corresponding field in the database entry as it completes, without watiting for the other operations to finish.

The framework currently consists of nine distinct operations, organized in an equal number of packages; three of those concern metadata information, while six more concern tampering localization algorithms.



## Extracting SURF or SIFT features from an image

This can be done using the classes in the `gr.iti.mklab.visual.extraction` package. `SURFExtractor `and `SIFTExtractor `implement SURF and SIFT extraction respectively and are actually wrappers of the corresponding classes in the [BoofCV][] library that only expose the most important parameters of the extraction process. Here is a simple example on how to extract SURF features from an image:

1.  Numbered list:

    `code`


[Link example][]

  [Link example]: https://code.google.com/p/efficient-java-matrix-library/

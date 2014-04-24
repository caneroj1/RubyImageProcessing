<h1>Ruby Image Processing, or RIP</h1>
<p>This repository contains code for an image processing library written in Ruby. It utilizes two gems:</p>
<ul>
  <li><a href="https://rubygems.org/gems/gosu">Gosu</a></li>
  <li><a href="https://rubygems.org/gems/chunky_png">ChunkyPNG</a></li>
</ul>
<p>ChunkyPNG is itself a gem specifically for image processing, but what I am writing is a high level wrapper that implements the functions of ChunkyPNG in such a way as to minimize the amount of code a user must write.</p>
<p>Gosu is a really awesome graphics gem, and it allows for visualization of images as you are working on them with a simple function call. I've also used Gosu to allow a user the ability to click on an image in order to generate a list of points that can be used for drawing.</p>
<hr>
<p>Working with images programmatically could be kind of annoying, and so I'm adding some functions to a Rakefile that will allow for easy maintenance of the directories in which a user is working.</p>
<h3>Getting Started</h3>
<p>Let's say you're working with an image file called "Lenna.png", and you plan on doing a lot of processing on this image. RIP will generate a lot of images as a result of its image processing functions (we might generate "LennaGrayed.png" if we convert it to grayscale), and cleaning up these files after you're done could be tedious.</p>
<p>We can use <pre>rake create</pre> to mark a file as a base image.<p>
<p>For example, <pre>rake create["Lenna.png"]</pre> will let RIP know you are working with Lenna.png as a base file.<p>
<p>We can also add more than one file at a time, like so: <pre>rake create["Lenna.png","image1.png","image2.png"]</pre></p>
<p>Be sure not include spaces between the files!</p>
<p>Now, assume that we're done with all of our image processing, and we've made a ton of files. We might have "Lenna.png", "LennaGrayed.png", "LennaBlurred.png", and so on. If we want to clean up what we've been working on, just call <pre>rake clean</pre></p>
<p>This will search through the "pictures" subdirectory and remove all of the pictures that have been created off of our baseline images while keeping the images we originally marked.</p>

<h1>Ruby Image Processing</h1>
<p>This repository contains code for an image processing library written in Ruby. It utilizes two gems:</p>
<ul>
  <li><a href="https://rubygems.org/gems/gosu">Gosu</a></li>
  <li><a href="https://rubygems.org/gems/chunky_png">ChunkyPNG</a></li>
</ul>
<p>ChunkyPNG is itself a gem specifically for image processing, but what I am writing is a high level wrapper that implements the functions of ChunkyPNG in such a way as to minimize the amount of code a user must write.</p>
<p>Gosu is a really awesome graphics gem, and it allows for visualization of images as you are working on them with a simple function call. I've also used Gosu to allow a user the ability to click on an image in order to generate a list of points that can be used for drawing.</p>

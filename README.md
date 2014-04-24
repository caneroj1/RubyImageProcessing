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
<p>Now, assume that we're done with all of our image processing and we've made a ton of files. We might have "Lenna.png", "LennaGrayed.png", "LennaBlurred.png", "LennaSharpened.png", and so on. If we want to clean up what we've been working on, just call <pre>rake clean</pre></p>
<p>This will search through the "pictures" subdirectory and remove all of the pictures that have been created off of our baseline images while keeping the images we originally marked.</p>
<hr>
<h3>Using RIP</h3>
<h4>Creating Images</h4>
<p>There are two main ways to create an Image object in RIP:</p>
<ul>
<li>With a image path (absolute or relative)</li>
</ul>
```ruby
picture = Image.new(pathToImage)
```
<ul>
<li>Without an image path</li>
</ul>
```ruby
picture = Image.new
```
<strong>It is highly recommended to create images with a path! It makes using RIP <em>so</em> much easier.</strong>
<p>For example, if we create our image with a path specified, parameters to various RIP functions are completely optional.</p>
```ruby
picture = Image.new(pathToImage)
picture.gaussianBlur
```
<p>This snippet shows you how to apply gaussian blur to an image. Since we created our image with a path, we do not need to specify the image we are working with, a path to save it, and a name to give the blurred image. RIP will save our blurred image in the same directory as the original image as well as append "Gauss.png" to the name. Cool, right?</p>
<p>On the other hand, if we create our image without a path, we need to specify the path to the image we are working with, the name we will give the new image, and a path to where we want to save it.</p>
```ruby
picture = Image.new
picture.gaussianBlur("blurred.png", pathToImage, pathToSave)
```
<p>This snippet accomplishes the same thing, but requires more work on the user's end.</p>
<p>We are also working on supporting drawing on images. Right now, the only function implemented is a bezier curve drawing function.</p>
```ruby
picture = Image.new(pathToImage)
picture.bezierCurve
```
<p>This snippet will bring up a window displaying the image we are working with. You can click anywhere within the image to mark control points for the curve. Hitting 'Esc' or 'Enter' will close the window and draw the appropriate bezier curve on the image, saving it in the same directory with "Bezier.png" appended to the name.</p>
<hr>
<h3>What can RIP do right now?</h3>

| Function | Syntax | Description |
| --- | --- | --- |
| Display | `picture.displayPicture` | Brings up a Gosu window displaying the current image. |
| Save | `picture.savePicture(name)` | Saves the current picture with the given name. Default path is the current image path |
| Grayscale | `picture.convertToGrayscale` | Converts the current picture into grayscale |
| Sobel | `picture.sobelFilter` | Applies Sobel Filters to the current picture in order to highlight edges |
| Blur | `picture.sobelFilter` | Applies a standard blur filter to the current picture. Not as strong as Gaussian Blur |
| Gaussian Blur | `picture.gaussianBlur` | Applies a Gaussian Blur filter to the current picture |
| Sharpen | `picture.sharpen` | Applies a filter to sharpen the image in order to highlight color changes |
| Bezier Curve | `picture.bezierCurve` | Allows the user to draw a bezier curve on the current picture by specifying control points |
| 1984 filter | `picture.surveillanceCamera` | Big Brother is watching you. |

<hr>
<h3>What are we working on?</h3>
<p>RIP is <em>far</em> from finished, and there is still a lot of work that needs to be done. Right now, there are few things we want to implement.</p>
<ul>
<li>Convert all functions to accept hashes for the parameters</li>
<li>Try and get bezier curve drawing to happen in real time</li>
<li>Implement more filters</li>
</ul>

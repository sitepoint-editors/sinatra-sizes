One of the great things about [Sinatra](http://www.sinatrarb.com/) is its lack of opinions. It lets you build applications any way you like. But this freedom can often be confusing - what is the best way to structure an application? Of course there's no one right answer to that question, but in this post I'm going to look at three different styles of structuring a Sinatra application.

Sinatra is often used to develop small applications and APIs, but it can easily cope with complex modular applications with large amounts of end points. I've chosen the names of the three different styles of application structure based on the size of the application:

* SMALL - all the code in a single file
* MEDIUM - tests in a separate file and a separate views folder
* LARGE - a modular-style application

To demonstrate each of these three different structures, I'm going to build an application, using exactly the same underlying code in each of the three styles.

The Application - A Caesar Shift Cipher
----------------------------------------
The application will add a method to the string class called `caesar_shift` that will encrypt the string using a [Caesar Shift Cipher](http://en.wikipedia.org/wiki/Caesar_cipher). There will be two route handlers needed for this application - one with a form to enter the string and one that displays the message in plaintext and ciphertext.


SMALL
--------------------------

[See the example application here](https://github.com/daz4126/sinatra-small)

A SMALL application is literally just a single file. Everything is in the same file: the code, route-handlers (controllers), helpers, views and even the tests. Yes that's right, the tests are in the same file as the app! This might seem completely nuts to some people, but I think that the fact that you can produce a full-stack application in just a single file is a truimph of Sinatra that is often overlooked.

This type of structure has the following advantages:

* Everything you need is right there in the same file. There is no need to change from the file you're editing to add a helper method or view, just add them to the same file!

* It's perfect when you only need a few route handlers and the views aren't too complicated.

* It's also useful if you're testing out an idea and want to whip up a proof of concept quickly.

Here's the first part of the application, which is simple saved in a file called __main.rb__ (or any other filename you prefer):

    require 'sinatra'

    class String

      def caesar_shift(shift=1)
        letters = ("a".."z").to_a
        ciphertext = []
        self.downcase.scan( /./ ) do |char|
          if letters.include?(char)
            ciphertext << letters[(letters.index(char)+shift)%26]
          else
            ciphertext << char
          end
        end
        ciphertext.join.upcase
      end
    end

In this code, we require Sinatra as usual, then open up the `String` class and add a `caesar_shift` method. The ne2w method uses `scan` to iterate over each character in a string and shift any letters along by the value of the `shift` argument, then capitalizes the result. Any values that aren't letters, for example punctuation are simply left as they are.

After this comes the helpers, in a block:

    helpers do
      def title
        @title || "Caesar Shift Cipher"
      end
    end

This is a straightforward helper for generating the title of the page. The title can be set in the route handler using the instance variable `@title`, otherwise it defaults to "Caesar Shift Cipher".

Next, it's the route handlers:

    get '/' do
      erb :form
    end

    post '/' do
      @title = "Secret Message"
      @plaintext = params[:plaintext].chomp
      shift = params[:shift].to_i
      @ciphertext = @plaintext.caesar_shift(shift)
      erb :result
    end

The first route handler just uses the `erb` helper method to display the 'form' view. The second route is used when the form is submitted via a post request. First of all, set the title of the page using the `@title` instance variable. Then, get the message from the form (stored in the `params` hash) and store it in an instance variable called `@plaintext`. Next, apply the `shift` parameter that was submitted in the form as an argument to the `caesar_shift` method. Take the result of `caeser_shift` and store it in an instance variable called `@ciphertext`.

The tests come next. In order to be able to run tests from within the same file, they need to go inside the following `if` statement:

    if ARGV.include? 'test'
      # tests go here
    end

This is testing to see if there is an argument of 'test' when the program is run.

If the argument is provided, then set the environment to 'test' and stop the Sinatra app from running:

    set :environment, :test
    set :run, false

Also, require the relevant testing gems:

    require 'test/unit'
    require 'rack/test'

The actual tests come next. I've written a couple that test the `caesar_shift` method and another that tests that a POST request actually returns an encrypted string:

    class CaesarCipherTest < Test::Unit::TestCase
      include Rack::Test::Methods

      def app
        Sinatra::Application
      end

      def test_it_can_encrypt_strings
        assert_equal 'JGNNQ','hello'.caesar_shift(2)
      end

      def test_it_can_encrypt_with_negative_shifts
        assert_equal 'GDKKN','hello'.caesar_shift(-1)
      end

      def test_it_can_encrypt_from_a_URL
        post '/', params={plaintext: 'hello', shift: '2'}
        assert last_response.ok?
        assert last_response.body.include?('hello'.caesar_shift(2))
      end

    end


To run the tests, simply enter the following in a terminal:

    ruby main.rb test

I discovered this method of adding tests to the same file as the application in a blog post by [Avdi and Dan](http://devver.wordpress.com/2009/05/13/single-file-sinatra-apps-with-specs-baked-in/).

Last of all come the views. Becuase we're using inline views, we need to mark out the end of the file:

    __END__

Each view's name then begins with the double ampersand `@@` with the code written in ERB:

    @@layout
    <!doctype html>
    <html>
      <head>
        <meta charset="utf-8">
        <title>Caesar Cipher</title>
      </head>
      <body>
        <h1>
          <a href='/''>Caesar Cipher</a>
        </h1>
        <%= yield %>
      </body>
    </html>

    @@form
      <form action='/' method='POST'>
        <textarea rows=4 cols=50 name='plaintext'>Enter plaintext</textarea>
        <input type='number' name='shift' value=1 min=1 max=26>
        <input type='submit' value='Encrypt'>
      </form>

    @@result
      <p>Plaintext:</p>
      <p><%= @plaintext %></p>
      <p>Ciphertext:</p>
      <p><%= @ciphertext %></p>
      <a href='/''>Write another message</a>

Medium Sized Application
------------------------

[See the example application here](https://github.com/daz4126/sinatra-medium)

A MEDIUM sized Sinatra application will still use the classic-style but will also add a views folder and have a separate file for tests. This is quite a common set up for most Sinatra projects and is often used in online tutorials.

The __main.rb__ file contains the helpers, the `caesar_shift` method, and the route handlers. In addition, the tests have been moved into their own file called __test.rb__ and the views have been moved into separate files and placed into a __views__ folder.

It has the following advantages:

* It still uses the classical-style, so all the route-handling code and helpers are all in one (__main.rb__). As a result, the benefit of all the code being in a single file remains.

* Views are kept in a separate folder. This is a useful structure to use once you start to have a large number of views or some very large and complex views.

* The tests are separated into their own file. This gets them out of the way of the main code, but keeps them all in one place.

All of the code in the Medium structure is identical to the code in the Small structure. The main difference is that it has been organized into different locations, making it easier to locate different pieces of code.


LARGE
----------------------

[See the example application here](https://github.com/daz4126/sinatra-large)

A LARGE Sinatra application uses Sinatra's modular-style structure and looks a lot more like a classic MVC-style architecture. In this structure, we still use separate folders for views, but we add folders for tests and helpers.

Another big difference is separating the route handlers from the `String` methods that implement the caesar cipher. The caesar cipher code should be able to be used as a standalone Ruby program that doesn't require Sinatra. For this reason, we put it in the __lib__ directory in a file called __caesar-cipher.rb__.

The route handlers are placed inside a `Controller` class that inherits from `Sinatra::Base` in the __controller.rb__ file:

    require 'sinatra/base'
    require_relative 'lib/caesar-cipher.rb'
    require_relative 'helpers/helpers.rb'

    class Controller < Sinatra::Base

      helpers TitleHelpers

      get '/' do
        erb :form
      end

      post '/' do
        @title = "Secret Message"
        @plaintext = params[:plaintext].chomp
        shift = params[:shift].to_i
        @ciphertext = @plaintext.caesar_shift(shift)
        erb :result
      end
    end

Notice that we have to explicitly register the helpers at the top of the `Controller` class using the line `helpers TitleHelpers`. This is because we have moved the helpers into a separate module in their own folder that contains a file called __helpers.rb__:

    module TitleHelpers
      def title
        @title || "Casaer Shift Cipher"
      end
    end

All the helpers are just in one module at the moment, but as the number of helper methods grows, we can separate them into different modules and only register the modules that we require in the controllers.

The tests are also placed into separate files based on whether they are testing the web application or the caesar cipher code. In this case, the result is one file for the `caesar_shift` method tests and another file for the route handler tests. To keep things DRY, we create a file called __test_helper.rb__ that includes all the setup code for the tests:

    ENV['RACK_ENV'] = 'test'

    require 'minitest/autorun'
    require 'rack/test'
    require_relative '../controller'

    include Rack::Test::Methods

This file is then required in all the other test files. For example, here is the __test_caesar-cipher.rb__ file:

    require_relative 'test_helper.rb'

    class CaesarCipherTest < MiniTest::Unit::TestCase

      def test_it_can_encrypt_strings
        assert_equal 'JGNNQ','hello'.caesar_shift(2)
      end

      def test_it_can_encrypt_with_negative_shifts
        assert_equal 'GDKKN','hello'.caesar_shift(-1)
      end
    end

To run the tests, use the following code:

    $ ruby test/test_website.rb
    $ ruby test/test_caesar-cipher.rb

The advantages of this style are:

* The code is modular, making it easier to reuse or develop independently.
* There is a clear separation of concerns. All of the route handlers are kept in controller classes and application code is kept in the __lib__ directory.
* Tests are separated based on what they are testing, making it easier to do more targeted testing.
* Helpers are kept in modules, making it easy to create different types of helper modules that can be used independently.

XL
----
If an application gets very large then it can start to outgrow even the LARGE structure. The next stage would be to break the application up into different modules and perhaps create a `Controller` class that other classes could subclass. Some of the helpers could also be turned into Sinatra extensions. This would create a structure similar to the [MVC framework I described building here](http://www.sitepoint.com/build-a-sinatra-mvc-framework/).

Many people would feel that Rails would be more suited for this type of application, but Sinatra is more than capable of handling such complex applications.

Summary
-----------
Which one of these is the best? Well, the good news is that you don't have to choose one or the other. In fact, the nice thing about all of these is that you can easily move up from one size to the next in a gradual fashion. You could have a great idea one day and put together some code all in the same file using the SMALL style, just to see if it works. Then as the number of route handlers, views, and tests begin to grow, break them out into their own separate files and use a MEDIUM style. After a while, as the project gets more complex, separate the different parts of the project into their own discrete classes and start to organize it into a LARGE modular structure.

The wonderful thing about working this way is just how organic it is - the application structure can change and adapt to fit the size of the application as it develops. If you've built the application from the ground up, starting SMALL, you will have a full understanding of how everything fits together as the application grows to MEDIUM and then to LARGE.

That's All Folks
-------------------
In this post, I have presented three different sizes of application structure that can be produced using Sinatra which hopefully demonstrate just how flexible it is. Do you think these three sizes cover everything?

Which "size" is the closest example to your Sinatra apps? Could Sinatra really be used to build an XL-sized application? Do you have anything else to add? As usual, leave your comments below.

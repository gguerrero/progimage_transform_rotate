# ProgImage Transformations Rotate

ProgImage Transformations Store is a RubyOnRails microservice which provide an
only endpoint for transform images by rotating them, it will look for the best
performance for the user by catching the image retrieval and the rotation query
(so further requests will became fasters and avoid overloading in the network).
This service will not have ActiveRecord nor DB connection keeping it as a reduced data isolated microservice which only concern about processing input images to
return an output transformed one.

## UpAndRunning
First run bundle to download all the dependencies for the project:
```
$ bundle install
```

Then navigate to the project folder and boot the server as usual:
```
$ bin/rails server
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
=> Run `rails server --help` for more startup options
Puma starting in single mode...
* Version 4.3.1 (ruby 2.6.5-p114), codename: Mysterious Traveller
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://127.0.0.1:3002
* Listening on tcp://[::1]:3002
Use Ctrl-C to stop
```

## Docker
In case you want to run the app with docker in production mode, you can build the image and use the `docker-compose.yml` config to run it locally. Inside `./docker/progimage_transform_rotate.dev.env` you'll find for related config for running the docker image, change it as required (DB connection, ports, etc.).

Building the image:
```
$ docker build . -t progimage_transform_rotate
Sending build context to Docker daemon  210.9kB
Step 1/12 : FROM ruby:2.6.5
 ---> dcb28425fa35
Step 2/12 : RUN apt-get update -qq &&   apt-get install -y imagemagick postgresql-client
 ---> Using cache
 ---> f34b392ef159
Step 3/12 : RUN mkdir /progimage_transform_rotate
 ---> Using cache
 ---> 0cfe4f6b3eae
Step 4/12 : WORKDIR /progimage_transform_rotate
 ---> Using cache
 ---> bf65db3ccd69
Step 5/12 : COPY Gemfile /progimage_transform_rotate/Gemfile
 ---> Using cache
 ---> 9abe35d394ea
Step 6/12 : COPY Gemfile.lock /progimage_transform_rotate/Gemfile.lock
 ---> 44fd645513b3
Step 7/12 : RUN bundle install --binstubs
 ---> Running in 71d463469362
The dependency tzinfo-data (>= 0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mingw32, x86-mswin32, x64-mingw32, java. To add those platforms to the bundle, run `bundle lock --add-platform x86-mingw32 x86-mswin32 x64-mingw32 java`.
Fetching gem metadata from https://rubygems.org/.........
...
Removing intermediate container 71d463469362
 ---> c0c4cabbaea4
Step 8/12 : COPY . /progimage_transform_rotate
 ---> 478638726a00
Step 9/12 : COPY docker/entrypoint.sh /usr/bin/
 ---> 65ae99853931
Step 10/12 : RUN chmod +x /usr/bin/entrypoint.sh
 ---> Running in c6e2ac0d3eb7
Removing intermediate container c6e2ac0d3eb7
 ---> cf4f0c6ee586
Step 11/12 : ENTRYPOINT ["entrypoint.sh"]
 ---> Running in d51a985debee
Removing intermediate container d51a985debee
 ---> 3c91f22cfdb9
Step 12/12 : CMD ["bin/rails", "server", "-b", "0.0.0.0"]
 ---> Running in 36771fb79182
Removing intermediate container 36771fb79182
 ---> 0d1b1d91610b
Successfully built 0d1b1d91610b
Successfully tagged progimage_transform_rotate:latest
```

And running docker compose:
```
$ docker-compose up progimage_transform_rotate
Recreating progimage_transform_rotate ... done
Attaching to progimage_transform_rotate
progimage_transform_rotate    | => Booting Puma
progimage_transform_rotate    | => Rails 6.0.2.1 application starting in production
progimage_transform_rotate    | => Run `rails server --help` for more startup options
progimage_transform_rotate    | Puma starting in single mode...
progimage_transform_rotate    | * Version 4.3.1 (ruby 2.6.5-p114), codename: Mysterious Traveller
progimage_transform_rotate    | * Min threads: 5, max threads: 5
progimage_transform_rotate    | * Environment: production
progimage_transform_rotate    | * Listening on tcp://0.0.0.0:3002
progimage_transform_rotate    | Use Ctrl-C to stop
```

## CLEAN Architecture
The projects follows CLEAN architecture principles in order to make different
layers for different kind of scopes. Look at
[ProgImage Store#clean-architecture](https://github.com/gguerrero/progimage_store#clean-architecture) section to learn more.

## API Endpoints
The project provides an updated collection for Postman if that's the client you use. You can download and export the [progimage_transform_rotate_postman_collection.json](/docs/progimage_transform_rotatepostman_collection.json) anytime.

Scoping all under `/api/v1` in order to provide future api versioning, you'll find 1 endpoint:

### GET /api/v1/transform/rotate/4a317f46-7ec0-4ec3-b4b3-9130c2c885e2

**HEADERS**
```
Contet-Type: application/json
```

**Input Query Params**
```
?degrees=-90
```

**200 OK Response**
```json
{
    "data": {
        "contentType": "image/png",
        "imageFilename": "ruby_logo.png",
        "imageData": "iVBORw0KGgoAAAANSUhEUgAAAVoAAAGJCAYAAADL..."
    }
}
```

**400 Bad Request Response**
```json
{
    "message": "param is missing or the value is empty: degrees"
}
```

**404 Not Found Response**
```json
{
    "message": "Not Found"
}
```

## Running Test Suite
In order to run the test suite provided in the project:

```
$ bin/rspec -f d

Api::V1::TransformController
  GET /api/v1/transform/rotate/:id
    when the uuid does not exist
      returns 404 Not Found with and error message
    when the remote store service is down
      returns 404 Not Found with and error message
    with invalid params
      returns 400 Bad Request with and error message
    with valid degrees param
      as JSON format
        returns 200 OK with a JSON payload containing the rotated image
      as HTML format
        returns 200 OK and send the image BLOB back to the user

Api::V1::TransformationSerializer
  serializing it as JSON
    returns a hash with the expected attributes

Resources::Adapters::Http
  when the remote service is down
    raises an custom error
  when remote service is up
    dowload the resource image if exists

Resources::Adapters::Http
  downloading an image
    raised and error if the response is not OK
    returns the data content of the dowload parsed response
  extracting the image data from some chunk of data
    returns only a valid BLOB byte string of the image

Transformations::Rotator
  #rotator
    return the BLOB of a given image data for the given degrees

Finished in 1.47 seconds (files took 2.29 seconds to load)
12 examples, 0 failures
```

## About
There are some topics about this project are are worth mention.

### No DB 🤔?
Even though a definition of microservice normally comes with `own his data`, for
this image transformation microservices we will not require to store data in disk.
Therefore we don't need `ActiveRecord` or DB connection making the service even ligther.
But is true that we will cache the image raw data for performance purposes...

### Adapters
In order to allow future networking improvements, the project introduces the concept
of adapters. These adapters in the service layer are referring to transport layers.
At the moment, the preferred transport layer will be HTTP, but in mid-term future we
may want to change the internal microservices transport layer for event-sourcing or
gRPC. In this case, we should only create new adapters for the transport that accomplish
the required interface in order to abstract other services that use them from change.
After completing the implementation of the new adapter we should change classes using it like this:

```ruby
module Resources
  class Images
    @adapter = Resources::Adapters::MyNewCoolTransport.new
    ...
  end

  class << self
    attr_reader :adapter

    def some_method
      # This is part of the defined interface
      adapter.download(image_uuid)
    end
  end
end
```

### Cache
A critical part of the application is caching the highly accessed resources.

That's why in the project we use 2 layers of catching:
- Image download cache: Once we request for the first time a `uuid` for an
image, and the request is successfully returned, we'll cache the response in order to
avoid future network request for a period of time. This is configurable and we have to
keep always in mind, that of this image is modified by the storage server, we'll need to
provide a cache invalidation mechanism (which currently is not required as the image is never modified).
- Rotate image query: Image process is CPU and Memory consuming task! That's why is worthy
to cache any transformation-rotation happening in the server for a short period of time, so in case the
same rotate request (with same parameters `uuid` and `degrees`) is happening in the server, we already
have the transformed image cached ready to return to the user. This cache improves highly the request performance!

See this in action, first request will have to download the image from the storage server and transform it.
When second request (with same params) is hit, the performance improve is clear (from 400ms -> 14ms):

```ruby
Started GET "/api/v1/transform/rotate/d86aaee4-a195-4432-8793-cf9ad47c9505?degrees=-90" for ::1 at 2020-02-24 19:23:17 +0400
Processing by Api::V1::TransformController#rotate as */*
  Parameters: {"degrees"=>"-90", "id"=>"d86aaee4-a195-4432-8793-cf9ad47c9505", "transform"=>{}}
Completed 200 OK in 402ms (Views: 9.4ms | Allocations: 537)


Started GET "/api/v1/transform/rotate/d86aaee4-a195-4432-8793-cf9ad47c9505?degrees=-90" for ::1 at 2020-02-24 19:23:30 +0400
Processing by Api::V1::TransformController#rotate as */*
  Parameters: {"degrees"=>"-90", "id"=>"d86aaee4-a195-4432-8793-cf9ad47c9505", "transform"=>{}}
Completed 200 OK in 14ms (Views: 10.4ms | Allocations: 253)
```

Caching is tricky, we need always to take care of invalidation and resource usage (memory in the server),
but they are an amazing ally when high performance is required!

#### Redis Store
A good practice and approach for the cache is also using a server like **Redis**.
Having a Redis server will allow to share the memory between the same nodes of a service
as well as between different microservices if required.

### Rails Template
This microservice is going to be one of many of a kind. Maybe we will create other
microservices that will just filter or convert the image.

That's why once we found this first microservice as stable, is highly recommended
using a [rails template](https://guides.rubyonrails.org/rails_application_templates.html)
containing many of the services, controller and even rspec files that this project has
by just accepting an input which will be the new kind of `transformation` that the microservice
will accomplish, helping the team to create in a super fashion and faster way as many
services as image transformation are required.

### Image Data Pipeline
Is a good idea to think in any of this image trasnformation microservices as data Pipeline.
Because we may want to apply many different fiters and transformation to the final image,
but they might be implemented in different microservices, any of these might accept not only a
UUID as input param (for retrieving the image from the Store) but also a raw base64 by string,
so we can just simply process it as the input image and return another base64 byte string as
and output to the user.

*Something to thing about in short-term.*

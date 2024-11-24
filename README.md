# Shelf Code Generator Example

This example demonstrates how to write and use a code generator for a [Shelf](https://pub.dev/packages/shelf) application.

## Running with the Dart SDK

You can run the example with the [Dart SDK](https://dart.dev/get-dart)
like this:

```
$ dart run bin/server.dart
Server listening on port 8080
```

And then from a second terminal:
```
$ curl -X POST \
  'http://localhost:8080/users/123' \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "id": "123",
    "name": "John Doe"
  }'
User updated: 123
```

# key-server assessment

## How to run
1. run `bundle i` 
2. run `rackup` to start server at `http://localhost:9292` 


## List of APIs

To test the API, you can use curl or Postman.
Example curl commands:
1. Generate a key:
```
curl -X POST http://localhost:4567/generate_key
```
2. Get an available key:
```
curl http://localhost:4567/key
```
3. Unblock a key:
```
curl -X POST http://localhost:4567/unblock_key/:key
```
4. Delete a key:
```
curl -X DELETE http://localhost:4567/key/:key
```
5. Keep alive a key:
```
curl -X POST http://localhost:4567/keep_alive/:key
```

Note: Replace :key with the actual key value you want to unblock, delete, or keep alive.
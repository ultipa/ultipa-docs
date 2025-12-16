# Login Ultipa Service

- Request URL
<p run-tag="false" graph="" tit= "URL" ></p>

```bash
.../login
```

- Request Example
<p run-tag="false" graph="" tit= "JSON" ></p>

```json
{
    "username": "employee",
    "password": "joaGsdf"
}
```

- Response: the token value after login

> The rest of API interfaces should all have this token value carried in Cookie in the Headers, `ultipa=<token_value>`, with Content_Type `application/json`.


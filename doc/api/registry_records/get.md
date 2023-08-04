# Query for Registry Records

Show a paginated list of all cases that are accessible to this user. The user can filter the case list based on search criteria. 

**URL** : `/api/v2/registry_records`

**Method** : `GET`

**Authentication** : YES

**Authorization** : The user must be authorized to view registry records in Primero.

**Parameters** : 

* `registry_type` Optional.
* `page` Optional. Pagination. Defaults to 1
* `per` Optional. Records per page. Defaults to 20. 

## Success Response

**Condition** : User can see one or more registry records. 

**Code** : `200 OK`

**Content** :

```json
{
  "data": [
    {
      "id": "96e28004-3c9e-42bd-885b-08a138139c1e",
      "enabled": true,
      "status": "open",
      "short_id": "9e86779",
      "created_at": "2022-02-04T21:44:57.056Z",
      "record_state": true,
      "registry_type": "foster_care",
      "last_updated_at": "2022-02-04T21:44:57.056Z",
      "associated_user_names": [],
      "record_in_scope": true,
      "alert_count": 0
    },
    {
      "id": "317e0667-e5ec-4c28-a9bc-e60ceb311168",
      "enabled": true,
      "status": "open",
      "short_id": "62bdf5f",
      "created_at": "2022-02-04T21:43:13.561Z",
      "record_state": true,
      "registry_type": "farmer",
      "last_updated_at": "2022-02-04T21:43:13.561Z",
      "associated_user_names": [],
      "record_in_scope": true,
      "alert_count": 0
    },
  ],
  "metadata": {
      "total": 2,
      "per": 20,
      "page": 1
  }
}
```
## Error Response

**Condition** : User isn't authorized to query for registry records. 

**Code** : `403 Forbidden`

**Content** :

```json
{
  "errors": [
    {
      "code": 403,
      "resource": "/api/v2/registry_records",
      "message": "Forbidden"
    }
  ]
}
```

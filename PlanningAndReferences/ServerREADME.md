# Drinky McDrunkface API
This is a living document, nothing is set in stone!

Last update: ```2017-02-06T05:25:15Z```

## Types
**All types will have the following properties:**

Key         | Value Type    | Description                                                   | Example
---         | ----------    | -----------                                                   | -------
id          | ```String```  | UUID of the entity.                                           | ```59BB1166-2C29-4E50-9411-773C71E09146```
createdAt   | ```String```  | An ISO 8601 Date and Time that the entity was created.        |```2017-02-06T05:03:15Z```
updatedAt   | ```String```  | An ISO 8601 Date and Time that the entity was last updated.   | ```2017-02-06T05:03:15Z```

### Glass
Key           | Value Type    | Description
---           | ----------    | -----------
name          | ```String```  | **Unique**, non-localized name of the glass.
displayName   | ```String```  | Localized name of the glass suitable for display to the end user.

### IngredientType
Key           | Value Type    | Description
---           | ----------    | -----------
name          | ```String```  | **Unique**, non-localized name of the type.
displayName   | ```String```  | Localized name of the type suitable for display to the end user.

### Ingredient
Key         | Value Type            | Description
---         | ----------            | -----------
name		  | ```String```          | **Unique**, non-localized name of the Ingredient.
displayName | ```String```          | Localized name of the ingredient suitable for display to the end user.
type        | ```IngredientType```  |
isAlcoholic | ```Boolean```         |

### Color
Key         | Value Type    | Description
---         | ----------    | -----------
name		  | ```String```  | **Unique**, non-localized name of the Color.
displayName | ```String```  | Localized name of the Color suitable for display to the end user.
r           | ```Integer``` | Red channel 0 - 255
g           | ```Integer``` | Green channel 0 - 255
b           | ```Integer``` | Blue channel 0 - 255
a           | ```Integer``` | Alpha channel 0 - 255

### Tool
Key         | Value Type    | Description
---         | ----------    | -----------
name		  | ```String```  | **Unique**, non-localized name of the Tool.
displayName | ```String```  | Localized name of the Tool suitable for display to the end user.
description | Text          | Localized description of, and how to use the tool.

### Drink
Key           | Value Type          | Description
---           | ----------          | -----------
name          | ```String```        | **Unique**, non-localized name of the Drink.
displayName   | ```String```        | Localized name of the Drink suitable for display to the end user.
ingredients   | [```Ingredient```]  |
isAlcoholic   | ```Boolean```       |
color         | ```Color```         |
tools         | [```Tool```]        |
glass         | ```Glass```         |
imageUrl      | ```String```        |
isIBAOfficial | ```Boolean```       |  
description   | ```String```        | Localized description of the Drink.

### DrinkPhoto
Key           | Value Type      | Description
---           | ----------      | -----------
drink         | ```Drink```     | The drink this photo is associated with.
url           | ```String```    |

### Location
Key           | Value Type   | Description
---           | ----------   | -----------
streetNum     | ```String``` | 
street        | ```String``` |
town          | ```String``` |
state         | ```String``` | Full state name. e.g. ```Georgia```
stateAbbr     | ```String``` | State abbreviation. e.g. ```GA```
zipCode       | ```Integer``` | 5 Digit Zip code. e.g. ```30312```
zipExp        | ```Integer``` | The +4 code. e.g. ```5408```
lat           | ```Float``` |
long          | ```Float``` |

### Bar
Key           | Value Type         | Description
---           | ----------         | -----------
inventory     | [```Ingredient```] | The ```Ingredient```s the Bar has on hand.
drinks        | [```Drink```]      | All of the ```Drink```s the bar *could* make with the ingredients they have.
menu          | [```Drink```]      | The ```Drink```s the bar is *willing* to make.
specialties   | [```Drink```]      | Specialty ```Drink```s the bar can make.
managers      | [```User```]       | Users that are allowed to make edits to the Bar.
location      | [```Location```]   | The physical location of the bar.

### User
Key           | Value Type         | Description
---           | ----------         | -----------
email         | ```String```       |
passwordHash  | ```String```       | A hash of the user's password. **This is never sent to client devices**.
inventory     | [```Ingredient```] | The ```Ingredient```s the User has on hand at home.
favorites     | [```Drink```]      |
barsManaged   | [```Bar```]        |


## Routes

### Authentication and Authorization
Coming soon to documentation near you!

### Content Negotiation
At the time of this writing all routes only accept and respond with json in english using the UTF-8 character set and optionally compressed with gzip. However, all content negotiation headers should still be sent to the server.

Hear are the HTTP request headers (not set automatically by URLSession) that should be included with all requests:

    Accept: application/json
    Accept-Language: en
    Accept-Encoding: gzip,identity
    Accept-Charset: utf-8

In all of the routes below, ```<content-negotiation-headers>``` will be used as a placeholder for the headers above.

You'll also notice ```HTTP/1.1``` after all of the URL lines in the request descriptions, you can safely ignore that for now, and pretend it's not written.

### Drink
An overview of all ```Drink``` routes.

Action               | Method | Path                            | Valid Query Params
------               | ------ | ----                            | ------------------
Get All Drinks       | GET    | ```/0/drinks```                 | isIBAOfficial
Get Specific Drink   | GET    | ```/0/drinks/<uuid>```          | N/A
Create Drink         | POST   | ```/0/drinks```                 | N/A
Update Drink         | PUT    | ```/0/drinks/<uuid>```          | N/A
Remove Drink         | DELETE | ```/0/drinks/<uuid>```          | N/A
Create Drink Photo   | POST   | ```/0/drinks/<uuid>/photos```   | N/A

#### Drink Route Examples
#### Get All Drinks
###### Request
    GET /0/drinks HTTP/1.1
    <content-negotiation-headers>
###### Response
    HTTP/1.1 200 OK
    Content-Type: application/json
    
    
    { "drinks": [Drink] }
    

#### Get IBA Official Drinks
###### Request
    GET /0/drinks?isIBAOfficial=true HTTP/1.1
    <content-negotiation-headers>
###### Response
    HTTP/1.1 200 OK
    Content-Type: application/json
    
    
    { "drinks": [Drink] }

#### Create Drink
###### Request
    POST /0/drinks HTTP/1.1
    <content-negotiation-headers>
    Content-Type: application/json
    
    
    { "drink" : Drink }
###### Response
    HTTP/1.1 201 Created
    Content-Type: application/json
    
    
    { "drink": Drink }

#### Get Specific Drink
###### Request
    GET /0/drinks/<UUID> HTTP/1.1
    <content-negotiation-headers>
###### Response
    HTTP/1.1 200 OK
    Content-Type: application/json
    
    
    { "drink": Drink }

#### Update Drink
This request will update the displayName and the description of the drink.
###### Request
    PUT /0/drinks/<UUID> HTTP/1.1
    <content-negotiation-headers>
    Content-Type: application/json
    
    
    { "update": { "description": "This is the new desc.", "displayName": "Tasty Drink" } }
The response will contain a complete, updated Drink object.
###### Response
    HTTP/1.1 200 OK
    Content-Type: application/json
    
    
    { "drink": Drink }

#### Remove Drink
###### Request
    DELETE /0/drinks/<UUID> HTTP/1.1
    <content-negotiation-headers>
###### Responses
The server will respond with 204 No Content, and no body upon success.
    
    HTTP/1.1 204 No Content
    
#### Create Drink Photo
###### Request
    POST /0/drinks/<UUID>/photos HTTP/1.1
    <content-negotiation-headers>
    Content-Type: image/jpeg
    
    
    ...raw jpeg image data...
###### Response
    HTTP/1.1 201 Created
    Content-Type: application/json
    
    
    { "drink": Drink }

### Ingredient

### Bar

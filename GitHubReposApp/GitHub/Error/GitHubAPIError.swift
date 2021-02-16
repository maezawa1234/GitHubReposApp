struct GitHubAPIError : Decodable ,Error{
    struct FieldError : Decodable{
        let resource: String
        let field: String
        let code: String
    }
    
    let message: String
    let fieldErrors: [FieldError]
}




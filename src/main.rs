use actix_web::{
    error::{ErrorInternalServerError, ErrorServiceUnavailable},
    get, App, HttpResponse, HttpServer, Responder, Result,
};

#[get("/ip")]
async fn query_external_ip() -> Result<impl Responder> {
    let resp = reqwest::get("https://httpbin.org/ip")
        .await
        .map_err(ErrorInternalServerError)?
        .bytes()
        .await
        .map_err(ErrorServiceUnavailable)?;

    Ok(HttpResponse::Ok().body(resp))
}

#[get("/hostname")]
async fn query_metadata_hostname() -> Result<impl Responder> {
    let resp = reqwest::get("http://169.254.169.254/latest/meta-data/hostname")
        .await
        .map_err(ErrorInternalServerError)?
        .bytes()
        .await
        .map_err(ErrorServiceUnavailable)?;

    Ok(HttpResponse::Ok().body(resp))
}

#[get("/iam")]
async fn query_metadata_iam() -> Result<impl Responder> {
    let resp = reqwest::get("http://169.254.169.254/latest/meta-data/iam")
        .await
        .map_err(ErrorInternalServerError)?
        .bytes()
        .await
        .map_err(ErrorServiceUnavailable)?;

    Ok(HttpResponse::Ok().body(resp))
}

#[get("/iam-info")]
async fn query_metadata_iam_info() -> Result<impl Responder> {
    let resp = reqwest::get("http://169.254.169.254/latest/meta-data/iam/info")
        .await
        .map_err(ErrorInternalServerError)?
        .bytes()
        .await
        .map_err(ErrorServiceUnavailable)?;

    Ok(HttpResponse::Ok().body(resp))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .service(query_external_ip)
            .service(query_metadata_hostname)
            .service(query_metadata_iam)
            .service(query_metadata_iam_info)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}

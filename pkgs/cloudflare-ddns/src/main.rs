use reqwest::{
  Method,
  blocking::{Client, RequestBuilder},
};
use serde_json::{Value, json};
use anyhow::{Context, Result, anyhow};

struct CfApi {
  client: Client,
  auth_token: String,
  zone: String,
  record: String,
}

enum IPVer { V4, V6 }

static API: &str = "https://api.cloudflare.com/client/v4";

impl CfApi {

  fn new(auth_token: String, zone: String, record: String) -> CfApi {
    CfApi {
      client: Client::new(),
      auth_token,
      zone,
      record
    }
  }

  fn request(&self, method: Method, function: impl AsRef<str>, query: impl AsRef<str>) -> reqwest::Result<RequestBuilder> {
    Ok(self
      .client
      .request(method, format!("{}/{}?{}", API, function.as_ref(), query.as_ref()))
      .bearer_auth(&self.auth_token)
    )
  }

  fn update_dns(&self, ipver: IPVer) -> Result<()> {
    let my_ip = match ipver {
      IPVer::V4 => get_my_ipv4()?,
      IPVer::V6 => get_my_ipv6()?
    };
    let record_type = match ipver {
      IPVer::V4 => "A",
      IPVer::V6 => "AAAA"
    };
    let zone_id = self
      .request(Method::GET, "zones", format!("name={}", self.zone))?
      .send()?
      .json::<Value>()?
      .to_cf_result()?
      .first_result()
      .context("Cannot get zone ID")?
      ["id"]
      .as_str()
      .unwrap()
      .to_owned();
    let record_id = self
      .request(Method::GET, format!("zones/{}/dns_records", zone_id), format!("name={}&type={}", self.record, record_type))?
      .send()?
      .json::<Value>()?
      .to_cf_result()?
      .first_result()
      .context("Cannot get record ID")?
      ["id"]
      .as_str()
      .unwrap()
      .to_owned();
    self
      .request(Method::PATCH, format!("zones/{}/dns_records/{}", zone_id, record_id), "")?
      .json(&json!({ "content": my_ip }))
      .send()?
      .json::<Value>()?
      .to_cf_result()?;
    Ok(())
  }

}

fn get_my_ipv4() -> Result<String> {
  Ok(Client::builder()
    .no_proxy()
    .build()?
    .get("https://4.ident.me")
    .send()?
    .text()?
  )
}

fn get_my_ipv6() -> Result<String> {
  Ok(Client::builder()
    .no_proxy()
    .build()?
    .get("https://6.ident.me")
    .send()?
    .text()?
  )
}

trait CfJson {
  fn to_cf_result(self) -> Result<Value>;
  fn first_result(&self) -> Result<&Value>;
}

impl CfJson for Value {
  fn to_cf_result(self) -> Result<Value> {
    if self["success"].as_bool().unwrap() {
      Ok(self)
    }
    else {
      Err(anyhow!("Cloudflare API error: {}", self))
    }
  }
  fn first_result(&self) -> Result<&Value> {
    self
      ["result"]
      .get(0)
      .ok_or_else(|| anyhow!("Cloudflare returned empty results"))
  }
}

fn main() {
  let cf_api = CfApi::new(
    std::env::var("CF_AUTH_TOKEN").expect("Please set environment variable CF_AUTH_TOKEN"),
    std::env::var("CF_ZONE").expect("Please set environment variable CF_ZONE"),
    std::env::var("CF_RECORD").expect("Please set environment variable CF_RECORD")
  );
  cf_api.update_dns(IPVer::V6).unwrap();
}

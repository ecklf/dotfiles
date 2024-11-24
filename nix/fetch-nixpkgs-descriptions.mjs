const IDENTIFIERS = [
  "pkgs.master.go-task",
  "pkgs.goreleaser",
  "pkgs.aws-iam-authenticator",
  "pkgs.lua51Packages.busted",
  "pkgs.lua51Packages.lua",
  "pkgs.lua51Packages.luacheck",
  "pkgs.lua51Packages.luafilesystem",
  "pkgs.lua51Packages.luarocks",
];

const fetchHits = async (identifier) => {
  const segments = identifier.split(".");
  const pkgName = segments[segments.length - 1];

  const result = await fetch(
    "https://search.nixos.org/backend/latest-42-nixos-24.05/_search",
    {
      headers: {
        accept: "*/*",
        "accept-language": "en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7",
        authorization: "Basic YVdWU0FMWHBadjpYOGdQSG56TDUyd0ZFZWt1eHNmUTljU2g=",
        "content-type": "application/json",
        priority: "u=1, i",
        "sec-ch-ua":
          '"Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"',
        "sec-ch-ua-mobile": "?0",
        "sec-ch-ua-platform": '"macOS"',
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-origin",
        Referer:
          "https://search.nixos.org/packages?channel=24.05&from=0&size=50&sort=relevance&type=packages&query=graphviz",
        "Referrer-Policy": "strict-origin-when-cross-origin",
      },
      body: `{"from":0,"size":50,"sort":[{"_score":"desc","package_attr_name":"desc","package_pversion":"desc"}],"aggs":{"package_attr_set":{"terms":{"field":"package_attr_set","size":20}},"package_license_set":{"terms":{"field":"package_license_set","size":20}},"package_maintainers_set":{"terms":{"field":"package_maintainers_set","size":20}},"package_platforms":{"terms":{"field":"package_platforms","size":20}},"all":{"global":{},"aggregations":{"package_attr_set":{"terms":{"field":"package_attr_set","size":20}},"package_license_set":{"terms":{"field":"package_license_set","size":20}},"package_maintainers_set":{"terms":{"field":"package_maintainers_set","size":20}},"package_platforms":{"terms":{"field":"package_platforms","size":20}}}}},"query":{"bool":{"filter":[{"term":{"type":{"value":"package","_name":"filter_packages"}}},{"bool":{"must":[{"bool":{"should":[]}},{"bool":{"should":[]}},{"bool":{"should":[]}},{"bool":{"should":[]}}]}}],"must":[{"dis_max":{"tie_breaker":0.7,"queries":[{"multi_match":{"type":"cross_fields","query":"${pkgName}","analyzer":"whitespace","auto_generate_synonyms_phrase_query":false,"operator":"and","_name":"multi_match_graphviz","fields":["package_attr_name^9","package_attr_name.*^5.3999999999999995","package_programs^9","package_programs.*^5.3999999999999995","package_pname^6","package_pname.*^3.5999999999999996","package_description^1.3","package_description.*^0.78","package_longDescription^1","package_longDescription.*^0.6","flake_name^0.5","flake_name.*^0.3"]}},{"wildcard":{"package_attr_name":{"value":"*graphviz*","case_insensitive":true}}}]}}]}}}`,
      method: "POST",
    },
  );
  const json = await result.json();
  const packageDescription =
    json.hits.hits.at(0)._source.package_description ?? "";
  return `${identifier} # ${packageDescription}`;
};

IDENTIFIERS.forEach(async (identifier) => {
  console.log(await fetchHits(identifier));
});

<!--
    IMPORTANT:
    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.
    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.
    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.
    - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.
    - To remove a policy, delete the corresponding policy statement from the policy document.
    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.
    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.
    - Policies are applied in the order of their appearance, from the top down.
    - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.
-->
<policies>
    <inbound>
        <base />
        <choose>
            <!-- Check if header exists, which means the request comes from an operator of PagoPA organization -->
            <when condition="@(context.Request.Headers.ContainsKey("organization-id") && (((Jwt)context.Variables["validatedToken"]).Claims.GetValueOrDefault("org_role", "").Equals("pagopa_admin")))">
                <set-variable name="organizationIdHeader" value="@(context.Request.Headers.GetValueOrDefault("organization-id",""))" />
                <choose>
                    <!-- If header not present than HTTP Status 400 -->
                    <when condition="@(String.IsNullOrEmpty((string)context.Variables["organizationIdHeader"]))">
                        <return-response>
                            <set-status code="400" reason="Bad Request" />
                        </return-response>
                    </when>
                    <!-- Otherwise header exist -->
                    <otherwise>
                        <!-- Get Organization Name from BE -->
                        <send-request mode="new" response-variable-name="organizationReturnedResponse" timeout="60" ignore-error="true">
                            <set-url>@("https://${ingress_load_balancer_hostname}/idpayportalwelfarebackendinitiative" + "/idpay/organizations/" + context.Variables["organizationIdHeader"])</set-url>
                            <set-method>GET</set-method>
                        </send-request>
                        <choose>
                            <when condition="@(((IResponse)context.Variables["organizationReturnedResponse"]).StatusCode == 200)">
                                <set-variable name="idpayPortalToken" value="@{
                                        Jwt idpayValidatedToken = (Jwt)context.Variables["validatedToken"];
                                        //var responseJObject = context.Response.Body.As<JObject>(preserveContent: true);
                                        var responseJObject = ((IResponse)context.Variables["organizationReturnedResponse"]).Body.As<JObject>(true);
                                        string organizationId = (string)responseJObject["organizationId"];
                                        string organizationName = (string)responseJObject["organizationName"];

                                        var JOSEProtectedHeader = Convert.ToBase64String(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(
                                            new {
                                                typ = "JWT",
                                                alg = "RS256"
                                            }))).Split('=')[0].Replace('+', '-').Replace('/', '_');

                                        var iat = DateTimeOffset.Now.ToUnixTimeSeconds();
                                        var exp = new DateTimeOffset(DateTime.Now.AddHours(8)).ToUnixTimeSeconds();  // sets the expiration of the token to be 8 hours from now
                                        var aud = "idpay.welfare.pagopa.it";
                                        var iss = "https://api-io.dev.cstar.pagopa.it";
                                        var uid = idpayValidatedToken.Claims.GetValueOrDefault("uid", "");
                                        var name = idpayValidatedToken.Claims.GetValueOrDefault("name", "");
                                        var family_name = idpayValidatedToken.Claims.GetValueOrDefault("family_name", "");
                                        var email = idpayValidatedToken.Claims.GetValueOrDefault("email", "");
                                        JObject organization = JObject.Parse(idpayValidatedToken.Claims.GetValueOrDefault("organization", "{}"));
                                        var org_id = organizationId;
                                        var org_vat = idpayValidatedToken.Claims.GetValueOrDefault("org_vat", "");
                                        var org_name = organizationName;
                                        var org_party_role = idpayValidatedToken.Claims.GetValueOrDefault("org_party_role", "");
                                        var org_role = idpayValidatedToken.Claims.GetValueOrDefault("org_role", "");
                                        var payload = Convert.ToBase64String(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(
                                        new {
                                        iat,
                                        exp,
                                        aud,
                                        iss,
                                        uid,
                                        name,
                                        family_name,
                                        email,
                                        org_id,
                                        org_vat,
                                        org_name,
                                        org_party_role,
                                        org_role
                                        }
                                        ))).Split('=')[0].Replace('+', '-').Replace('/', '_');

                                        var message = ($"{JOSEProtectedHeader}.{payload}");

                                        using (RSA rsa = context.Deployment.Certificates["${jwt_cert_signing_thumbprint}"].GetRSAPrivateKey())
                                        {
                                            var signature = rsa.SignData(Encoding.UTF8.GetBytes(message), HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
                                            return message + "." + Convert.ToBase64String(signature).Split('=')[0].Replace('+', '-').Replace('/', '_');
                                        }

                                        return message;
                                        }" />
                                <return-response>
                                    <set-body>@((string)context.Variables["idpayPortalToken"])</set-body>
                                </return-response>
                            </when>
                            <otherwise>
                                <return-response>
                                    <set-status code="@(((IResponse)context.Variables["organizationReturnedResponse"]).StatusCode)" reason="@(((IResponse)context.Variables["organizationReturnedResponse"]).StatusReason)" />
                                    <set-body />
                                </return-response>
                            </otherwise>
                        </choose>
                    </otherwise>
                </choose>
            </when>
            <!-- Otherwise header does not exist. Sample request from any operator (not belonging PagoPA organization)-->
            <otherwise>
                <return-response>
                    <set-status code="400" reason="Bad Request" />
                </return-response>
            </otherwise>
        </choose>
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>

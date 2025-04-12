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
        <set-variable name="pii" value="@(context.Request.Headers.GetValueOrDefault("Fiscal-Code"))" />
        <include-fragment fragment-id="idpay-pdv-tokenizer" />
        <choose>
          <when condition="@(context.Variables["pdv_token"] != null)">
            <set-backend-service base-url="https://${ingress_load_balancer_hostname}/idpayrewardnotification" />
            <rewrite-uri template="@("/idpay/organization/"+((Jwt)context.Variables["validatedToken"]).Claims.GetValueOrDefault("org_id", "")+"/initiative/{initiativeId}/user/"+(context.Variables["pdv_token"])+"/suspend")" />
          </when>
          <otherwise>
            <return-response>
              <set-status code="401" reason="Unauthorized" />
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

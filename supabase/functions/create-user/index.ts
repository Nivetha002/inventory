import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed." }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");

    if (!authHeader) {
      return jsonResponse({ error: "Please log in first." }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey =
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Verify the currently logged-in user.
    const userClient = createClient(supabaseUrl, anonKey, {
      global: {
        headers: { Authorization: authHeader },
      },
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });

    const {
      data: { user: currentUser },
      error: authError,
    } = await userClient.auth.getUser();

    if (authError || !currentUser) {
      return jsonResponse({ error: "Unauthorized." }, 401);
    }

    // Only an active ADMIN can create users.
    const { data: adminProfile, error: profileError } =
      await userClient
        .from("profiles")
        .select("role, is_active")
        .eq("id", currentUser.id)
        .maybeSingle();

    if (
      profileError ||
      adminProfile?.role !== "ADMIN" ||
      adminProfile?.is_active !== true
    ) {
      return jsonResponse(
        { error: "Only active admins can create users." },
        403,
      );
    }

    const body = await req.json();

    const fullName = String(body.fullName ?? "").trim();
    const username = String(body.username ?? "").trim();
    const email = String(body.email ?? "").trim().toLowerCase();
    const password = String(body.password ?? "");
    const role = String(body.role ?? "");

    if (!fullName || !username || !email || !password || !role) {
      return jsonResponse(
        { error: "All fields are required." },
        400,
      );
    }

    if (password.length < 6) {
      return jsonResponse(
        { error: "Password must contain at least 6 characters." },
        400,
      );
    }

    if (!["ADMIN", "MANAGER", "CASHIER"].includes(role)) {
      return jsonResponse({ error: "Invalid role." }, 400);
    }

    // Admin API: this key must remain on the server.
    const adminClient = createClient(
      supabaseUrl,
      serviceRoleKey,
      {
        auth: {
          persistSession: false,
          autoRefreshToken: false,
        },
      },
    );

    const { data: existingUsername, error: usernameError } =
      await adminClient
        .from("profiles")
        .select("id")
        .eq("username", username)
        .maybeSingle();

    if (usernameError) {
      return jsonResponse(
        { error: "Unable to check username." },
        500,
      );
    }

    if (existingUsername) {
      return jsonResponse(
        { error: "Username already exists." },
        409,
      );
    }

    // Create the authentication account.
    const {
      data: authData,
      error: createAuthError,
    } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });

    if (createAuthError || !authData.user) {
      return jsonResponse(
        {
          error: createAuthError?.message ??
            "Unable to create authentication account.",
        },
        400,
      );
    }

    // Create the corresponding application profile.
    const { error: insertError } = await adminClient
      .from("profiles")
      .insert({
        id: authData.user.id,
        full_name: fullName,
        username,
        email,
        role,
        is_active: true,
      });

    if (insertError) {
      // Roll back the Auth account if profile creation fails.
      await adminClient.auth.admin.deleteUser(authData.user.id);

      return jsonResponse(
        { error: "Unable to create user profile." },
        500,
      );
    }

    return jsonResponse(
      {
        message: "User created successfully.",
        userId: authData.user.id,
      },
      201,
    );
  } catch (error) {
    console.error("create-user error:", error);

    return jsonResponse(
      { error: "An unexpected error occurred." },
      500,
    );
  }
});
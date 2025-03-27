import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.0.0";

console.log("Delete user account function is running...");

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*", // Allow all origins
        "Access-Control-Allow-Methods": "OPTIONS, POST, GET",
        "Access-Control-Allow-Headers": "Authorization, Content-Type",
      },
      status: 204,
    });
  }

  try {
    const supabaseClient = createClient(
          "https://txuvmmvubieskhcwwmrh.supabase.co",
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4dXZtbXZ1Ymllc2toY3d3bXJoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMzk0NDUyMywiZXhwIjoyMDQ5NTIwNTIzfQ.rtWr1dE59I0xdS1knCWpPm17v7guSj9i_yRzIbu3rD0",
        );

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) throw new Error("Authorization token missing!");

    const jwt = authHeader.replace("Bearer ", "");
    const { data: { user } } = await supabaseClient.auth.getUser(jwt);

    if (!user) throw new Error("User not found!");

    // Delete user
    const { error } = await supabaseClient.auth.admin.deleteUser(user.id);
    if (error) throw error;

    return new Response(JSON.stringify({ success: true }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      status: 200,
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      status: 400,
    });
  }
});

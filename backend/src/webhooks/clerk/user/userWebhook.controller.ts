import { Webhook } from "svix";
import { error, log } from "../../../utils/logger.js";
import User from "../../../features/user/user.model.js";

const userWebhookController = async (req, res) => {
  const WEBHOOK_SECRET = process.env.CLERK_WEBHOOK_SECRET;

  if (!WEBHOOK_SECRET) {
    error("Missing CLERK_WEBHOOK_SECRET");
    return res.status(500).send("Server misconfigured");
  }

  const payload = req.body;
  const headers = req.headers;

  const svix_id = headers["svix-id"];
  const svix_timestamp = headers["svix-timestamp"];
  const svix_signature = headers["svix-signature"];

  if (!svix_id || !svix_timestamp || !svix_signature) {
    return res.status(400).send("Missing Svix headers");
  }

  const wh = new Webhook(WEBHOOK_SECRET);

  let evt;

  try {
    evt = wh.verify(payload, {
      "svix-id": svix_id,
      "svix-timestamp": svix_timestamp,
      "svix-signature": svix_signature,
    });
  } catch (err) {
    error(`Webhook verification failed: ${err}`);
    return res.status(400).send("Invalid signature");
  }

  const { type, data } = evt;

  log(`Webhook event received: ${type}`);

  try {
    switch (type) {
      case "user.created": {
        const email =
          data.email_addresses?.find((e) => e.primary)?.email_address ??
          data.email_addresses?.[0]?.email_address;

        await User.create({
          uuid: data.id,
          email,
          firstName: data.first_name || "",
          lastName: data.last_name || "",
        });

        log(`User created in DB: ${data.id}`);
        break;
      }

      case "user.updated": {
        const email =
          data.email_addresses?.find((e) => e.primary)?.email_address ??
          data.email_addresses?.[0]?.email_address;

        const mobile =
          data.phone_numbers?.find((p) => p.primary)?.phone_number ??
          data.phone_numbers?.[0]?.phone_number;

        await User.findOneAndUpdate(
          { uuid: data.id },
          {
            email,
            firstName: data.first_name || "",
            lastName: data.last_name || "",
            mobile,
          },
          { new: true }
        );

        log(`User updated in DB: ${data.id}`);
        break;
      }

      case "user.deleted": {
        await User.findOneAndDelete({ uuid: data.id });
        log(`User deleted from DB: ${data.id}`);
        break;
      }

      default:
        log(`Unhandled event type: ${type}`);
    }
  } catch (dbError) {
    error(`Database error: ${dbError}`);
    return res.status(500).send("Database operation failed");
  }

  res.status(200).json({ success: true });
};

export default userWebhookController;

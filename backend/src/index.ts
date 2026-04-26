import express from "express";
import http from "http";
import cors from "cors";
import { log } from "./utils/logger.js";
import connectDB from "./config/db.config.js";

import authRoutes from "./features/auth/auth.routes.js";
import userRoutes from "./features/user/user.routes.js";
import webhookRoutes from "./webhooks/clerk/user/userWebhook.routes.js";
import businessRoutes from "./features/business/business.routes.js";
import directoryRoutes from "./features/directory/directory.routes.js";
import newsRoutes from "./features/news/news.routes.js";
import jobRoutes from "./features/jobs/job.routes.js";
import { backfillDates } from "./scripts/backfillDates.js";

const app = express();
const server = http.createServer(app);

app.use(
  "/api/v1/webhook",
  express.raw({ type: "application/json" }),
  webhookRoutes,
);

app.use(express.json());
app.use(
  cors({
    origin: "*",
  }),
);

app.use("/api/v1/auth", authRoutes);
app.use("/api/v1/user", userRoutes);
app.use("/api/v1/business", businessRoutes);
app.use("/api/v1/directory", directoryRoutes);
app.use("/api/v1/news", newsRoutes);
app.use("/api/v1/jobs", jobRoutes);

server.listen(process.env.PORT || 3000, () => {
  log("Server is running...");
  connectDB();
});

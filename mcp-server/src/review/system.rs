use crate::db::DbPool;
use anyhow::Result;
use chrono::{Duration, Utc};
use sqlx::Row;
use uuid::Uuid;

#[derive(Clone)]
pub struct ReviewSystem {
    pool: DbPool,
}

impl ReviewSystem {
    pub fn new(pool: DbPool) -> Self {
        Self { pool }
    }

    pub async fn create_review_request(
        &self,
        requesting_agent: String,
        target_agent: String,
    ) -> Result<String> {
        let request_id = Uuid::new_v4().to_string();
        let deadline = (Utc::now() + Duration::hours(24)).to_rfc3339();

        self.create_review_request_with_id(
            &request_id,
            &requesting_agent,
            &target_agent,
            "UNSPECIFIED_WORK_PACKAGE",
            "",
            "normal",
            &deadline,
        )
        .await?;

        Ok(request_id)
    }

    pub async fn create_review_request_with_id(
        &self,
        request_id: &str,
        requesting_agent: &str,
        target_agent: &str,
        work_package_id: &str,
        context: &str,
        priority: &str,
        deadline: &str,
    ) -> Result<()> {
        let created_at = Utc::now().to_rfc3339();

        sqlx::query(
            "INSERT INTO review_requests \
             (request_id, requesting_agent, target_agent, work_package_id, artifacts_to_review, context, priority, status, created_at, deadline) \
             VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?)",
        )
        .bind(request_id)
        .bind(requesting_agent)
        .bind(target_agent)
        .bind(work_package_id)
        .bind("[]")
        .bind(context)
        .bind(priority)
        .bind(created_at)
        .bind(deadline)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    pub async fn submit_review_response(
        &self,
        request_id: &str,
        reviewing_agent: &str,
        findings: &str,
        decision: &str,
    ) -> Result<String> {
        let normalized_decision = normalize_decision(decision)?;
        let request_status = map_decision_to_request_status(normalized_decision);

        let mut tx = self.pool.begin().await?;

        let current = sqlx::query("SELECT status FROM review_requests WHERE request_id = ?")
            .bind(request_id)
            .fetch_optional(&mut *tx)
            .await?;

        let Some(current) = current else {
            return Err(anyhow::anyhow!("review request not found: {}", request_id));
        };

        let current_status: String = current.get("status");
        if current_status != "pending" {
            return Err(anyhow::anyhow!(
                "review request {} is not pending (current status: {})",
                request_id,
                current_status
            ));
        }

        let response_id = Uuid::new_v4().to_string();
        let created_at = Utc::now().to_rfc3339();

        sqlx::query(
            "INSERT INTO review_responses \
             (response_id, request_id, reviewing_agent, findings, recommendations, approval_decision, signature, created_at) \
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        )
        .bind(&response_id)
        .bind(request_id)
        .bind(reviewing_agent)
        .bind(findings)
        .bind("[]")
        .bind(normalized_decision)
        .bind("")
        .bind(created_at)
        .execute(&mut *tx)
        .await?;

        sqlx::query("UPDATE review_requests SET status = ? WHERE request_id = ?")
            .bind(request_status)
            .bind(request_id)
            .execute(&mut *tx)
            .await?;

        tx.commit().await?;

        Ok(response_id)
    }

    pub async fn get_review_request_target(
        &self,
        request_id: &str,
    ) -> Result<Option<(String, String)>> {
        let row =
            sqlx::query("SELECT target_agent, status FROM review_requests WHERE request_id = ?")
                .bind(request_id)
                .fetch_optional(&self.pool)
                .await?;

        if let Some(row) = row {
            let target_agent: String = row.get("target_agent");
            let status: String = row.get("status");
            Ok(Some((target_agent, status)))
        } else {
            Ok(None)
        }
    }

    pub async fn pending_review_count(&self) -> Result<u32> {
        let count: i64 =
            sqlx::query_scalar("SELECT COUNT(*) FROM review_requests WHERE status = 'pending'")
                .fetch_one(&self.pool)
                .await?;

        Ok(count as u32)
    }
}

fn normalize_decision(decision: &str) -> Result<&'static str> {
    let normalized = decision.trim().to_ascii_lowercase();
    match normalized.as_str() {
        "approve" | "approved" => Ok("approved"),
        "reject" | "rejected" => Ok("rejected"),
        "conditional" | "conditional_approval" => Ok("conditional"),
        _ => Err(anyhow::anyhow!(
            "invalid decision '{}'; expected approve/approved, reject/rejected, or conditional",
            decision
        )),
    }
}

fn map_decision_to_request_status(_decision: &str) -> &'static str {
    "completed"
}

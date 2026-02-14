use anyhow::{Context, Result};
use sqlx::{Pool, Sqlite, SqlitePool};
use tracing::info;

pub type DbPool = Pool<Sqlite>;

pub async fn create_pool(database_url: &str) -> Result<DbPool> {
    info!("Creating database connection pool...");

    let pool = SqlitePool::connect(database_url)
        .await
        .context("Failed to create database connection pool")?;

    run_migrations(&pool).await?;

    info!("Database initialized successfully");
    Ok(pool)
}

async fn run_migrations(pool: &DbPool) -> Result<()> {
    let schema = include_str!("../../migrations/init.sql");
    sqlx::query(schema)
        .execute(pool)
        .await
        .context("Failed to run migrations")?;

    Ok(())
}

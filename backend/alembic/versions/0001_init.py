"""create initial secure vibe schema

Revision ID: 0001_init
Revises: 
Create Date: 2026-02-24
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "0001_init"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    habit_type = sa.Enum("CHAKRA", "VITALITY", "FOCUS", name="habit_type")
    habit_schedule = sa.Enum("DAILY", "RECURRING", "ONE_OFF", name="habit_schedule")

    op.create_table(
        "users",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("email", sa.String(length=320), nullable=False),
        sa.Column("hashed_password", sa.String(length=512), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)

    op.create_table(
        "habits",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("user_id", sa.String(length=36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("title", sa.String(length=120), nullable=False),
        sa.Column("description", sa.String(length=240), nullable=False),
        sa.Column("type", habit_type, nullable=False),
        sa.Column("schedule", habit_schedule, nullable=False),
        sa.Column("completed", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_habits_user_id", "habits", ["user_id"])
    op.create_index("ix_habits_type", "habits", ["type"])
    op.create_index("ix_habit_user_schedule", "habits", ["user_id", "schedule"])

    op.create_table(
        "completions",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("habit_id", sa.String(length=36), sa.ForeignKey("habits.id", ondelete="CASCADE"), nullable=False),
        sa.Column("user_id", sa.String(length=36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("completed", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_completions_habit_id", "completions", ["habit_id"])
    op.create_index("ix_completions_user_id", "completions", ["user_id"])
    op.create_index("ix_completions_created_at", "completions", ["created_at"])
    op.create_index("ix_completion_user_time", "completions", ["user_id", "created_at"])

    op.create_table(
        "stats",
        sa.Column("user_id", sa.String(length=36), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("chakra_xp", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("vitality_xp", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("focus_xp", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )

    op.create_table(
        "quests",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("user_id", sa.String(length=36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("title", sa.String(length=160), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("notes", sa.Text(), nullable=False),
    )
    op.create_index("ix_quests_user_id", "quests", ["user_id"])

    op.create_table(
        "avatar_states",
        sa.Column("user_id", sa.String(length=36), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("aura_level", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("aura_label", sa.String(length=64), nullable=False, server_default="Dormant"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )


def downgrade() -> None:
    op.drop_table("avatar_states")
    op.drop_index("ix_quests_user_id", table_name="quests")
    op.drop_table("quests")
    op.drop_table("stats")
    op.drop_index("ix_completion_user_time", table_name="completions")
    op.drop_index("ix_completions_created_at", table_name="completions")
    op.drop_index("ix_completions_user_id", table_name="completions")
    op.drop_index("ix_completions_habit_id", table_name="completions")
    op.drop_table("completions")
    op.drop_index("ix_habit_user_schedule", table_name="habits")
    op.drop_index("ix_habits_type", table_name="habits")
    op.drop_index("ix_habits_user_id", table_name="habits")
    op.drop_table("habits")
    op.drop_index("ix_users_email", table_name="users")
    op.drop_table("users")

    sa.Enum(name="habit_type").drop(op.get_bind(), checkfirst=True)
    sa.Enum(name="habit_schedule").drop(op.get_bind(), checkfirst=True)

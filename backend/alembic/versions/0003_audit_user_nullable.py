"""allow nullable user_id in audit logs

Revision ID: 0003_audit_user_nullable
Revises: 0002_audit_logs
Create Date: 2026-02-24
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "0003_audit_user_nullable"
down_revision: Union[str, None] = "0002_audit_logs"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with op.batch_alter_table("audit_logs") as batch_op:
        batch_op.alter_column(
            "user_id",
            existing_type=sa.String(length=36),
            nullable=True,
        )


def downgrade() -> None:
    with op.batch_alter_table("audit_logs") as batch_op:
        batch_op.alter_column(
            "user_id",
            existing_type=sa.String(length=36),
            nullable=False,
        )

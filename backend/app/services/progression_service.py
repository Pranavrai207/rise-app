from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy.orm import Session

from app.models.entities import AvatarState, Completion, Habit, HabitType, Stats
from app.services.audit_service import AuditService


class ProgressionService:
    xp_per_completion = 120

    def recompute_user_progression(self, db: Session, user_id: str) -> tuple[Stats, AvatarState]:
        rows = (
            db.query(Habit.type)
            .join(Completion, Completion.habit_id == Habit.id)
            .filter(
                Completion.user_id == user_id,
                Completion.completed.is_(True),
                Habit.user_id == user_id,
            )
            .all()
        )

        chakra_count = 0
        vitality_count = 0
        focus_count = 0
        for row in rows:
            if row[0] == HabitType.chakra:
                chakra_count += 1
            elif row[0] == HabitType.vitality:
                vitality_count += 1
            elif row[0] == HabitType.focus:
                focus_count += 1

        chakra_xp = chakra_count * self.xp_per_completion
        vitality_xp = vitality_count * self.xp_per_completion
        focus_xp = focus_count * self.xp_per_completion
        total_xp = chakra_xp + vitality_xp + focus_xp

        stats = db.query(Stats).filter(Stats.user_id == user_id).first()
        if stats is None:
            stats = Stats(user_id=user_id)
        previous_stats = (stats.chakra_xp, stats.vitality_xp, stats.focus_xp)

        stats.chakra_xp = chakra_xp
        stats.vitality_xp = vitality_xp
        stats.focus_xp = focus_xp
        stats.updated_at = datetime.now(UTC)

        aura_level, aura_label = self._derive_aura(total_xp)
        avatar = db.query(AvatarState).filter(AvatarState.user_id == user_id).first()
        if avatar is None:
            avatar = AvatarState(user_id=user_id)
        previous_avatar = (avatar.aura_level, avatar.aura_label)

        avatar.aura_level = aura_level
        avatar.aura_label = aura_label
        avatar.updated_at = datetime.now(UTC)

        db.add(stats)
        db.add(avatar)
        if previous_stats != (chakra_xp, vitality_xp, focus_xp) or previous_avatar != (aura_level, aura_label):
            AuditService().log_event(
                db,
                user_id=user_id,
                event_type="progression_recomputed",
                entity_type="stats",
                entity_id=user_id,
                details={
                    "chakra_xp": chakra_xp,
                    "vitality_xp": vitality_xp,
                    "focus_xp": focus_xp,
                    "aura_level": aura_level,
                    "aura_label": aura_label,
                    "total_xp": total_xp,
                },
            )

        return stats, avatar

    @staticmethod
    def _derive_aura(total_xp: int) -> tuple[int, str]:
        if total_xp >= 1200:
            return 3, "Transcendent"
        if total_xp >= 600:
            return 2, "Radiant"
        if total_xp >= 240:
            return 1, "Stirring"
        return 0, "Dormant"

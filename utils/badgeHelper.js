// utils/badgeHelper.js

const BADGE_RULES = [
  { 
    id: 'first_steps', 
    points: 50, 
    condition: (user) => (user.chordsMastered || 0) >= 1 || (user.practiceSessions?.length || 0) >= 1 
  },
  { 
    id: 'week_warrior', 
    points: 150, 
    condition: (user) => (user.streak || 0) >= 7 
  },
  { 
    id: 'perfect_pitch', 
    points: 200, 
    condition: (user) => (user.accuracy || 0) >= 100 
  },
  { 
    id: 'chord_master', 
    points: 500, 
    condition: (user) => (user.chordsMastered || 0) >= 50 
  },
  { 
    id: 'practice_legend', 
    points: 750, 
    condition: (user) => (user.practiceSessions?.length || 0) >= 100 
  },
  { 
    id: 'speed_demon', 
    points: 1000, 
    condition: (user) => false 
  },
];

async function checkAndAwardBadges(user) {
  console.log(`\n🔍 [BADGE CHECK] Checking user: ${user?.username} (ID: ${user?._id})`);
  console.log(`   Current Stats -> Chords: ${user?.chordsMastered}, Streak: ${user?.streak}, Accuracy: ${user?.accuracy}`);
  
  if (!user.unlockedBadges) {
    user.unlockedBadges = [];
  }

  let newPointsAwarded = 0;

  for (const badge of BADGE_RULES) {
    const passed = badge.condition(user);
    const alreadyUnlocked = user.unlockedBadges.includes(badge.id);
    
    console.log(`   Badge: ${badge.id} | Condition Met: ${passed} | Already Unlocked: ${alreadyUnlocked}`);

    if (passed && !alreadyUnlocked) {
      user.unlockedBadges.push(badge.id);
      newPointsAwarded += badge.points;
      console.log(`   🎉 MATCH FOUND! Awarding ${badge.id} (+${badge.points} pts)`);
    }
  }

  if (newPointsAwarded > 0) {
    user.totalPoints = (user.totalPoints || 0) + newPointsAwarded;
    user.markModified('unlockedBadges');
    await user.save();
    console.log(`   💾 SUCCESS! Saved new totalPoints: ${user.totalPoints}, Badges:`, user.unlockedBadges);
  } else {
    console.log(`   ℹ️ No new badges awarded.`);
  }

  return user;
}

module.exports = { checkAndAwardBadges };
AGSScriptModule      Combat 1.0 ��  // Combat module script

/* Constants **********************************************************************************/

#define MAX_ENEMIES 5


/* Enums and structs  *************************************************************************/

enum EnemyType
{
	EnType_Hobgoblin = 0,
	EnType_ShadowMage,
	EnType_ClayGolem,
	EnType_WoodGolem,
	EnType_Rogue,
	EnType_Boggle,
	EnType_Drake,
	EnType_Max
};

// hero combat anim loops
enum CombatAnim
{
	CbAnim_Block = 0,
	CbAnim_Dodge, 
	// todo - change these to attacks and spells names
	CbAnim_Attack1,
	CbAnim_Attack2,
	CbAnim_Attack3,
	CbAnim_Spell1,
	CbAnim_Spell2,
	CbAnim_Spell3,
	CbAnim_Spell4,
	CbAnim_Spell5,
	CbAnim_Flinch,
};

// combat animations:
// -----------------

// 0 - Attack1 (toughest)
// 1 - Flinch
// 2 - Death
// 3 - Ambient anim
// 4 - Attack2 (intermediate) 
// 5 - Attack3 
// 6 - Block/Dodge

// enemy combat anim loops
enum EnemyCombatAnim
{
	ECbAnim_Attack1 = 0,
	ECbAnim_Death = 1,
	ECbAnim_Flinch = 2,
	ECbAnim_Idle = 3,
	ECbAnim_Attack2 = 4,
	ECbAnim_Attack3 = 5,
	ECbAnim_Block = 6
};

/* Global vars  ******************************************************************************/
// script "global" vars (game global has export)

int combatRoomId = 102;
int heroCombatView = 11;
//combatAreas[2] = {SCENE_TYPE_ROAD, SCENE_TYPE_N_FOREST};

int dist;
int currEnemyId;

// todo - incorporate this and remove monster vars
int nEnemies;		// # of current enemies attacking hero
Character* dummyChars[MAX_ENEMIES];
Enemy enemies[MAX_ENEMIES];
Enemy enemyTypes[EnType_Max];

// monster vars -
// todo - kill these and use only enemy structs
Enemy combatMonster;  

  
// combat action vars
bool heroInCombat = false;
bool defeatedInCombat = false;
bool heroHitEnemy;			// if hit frame was reached in hero attack anim
bool enemyHitHero;			// if hit frame was reached in enemy attack anim



/**** Functions ******************************************************************************************************************/


short getFirstAliveEnemyId()
{
  short i=0;
  bool flag = true;
  
	while (i < nEnemies && flag)
	{
	  //if (i>0)
		//	Display(String.Format("getFirstAliveEnemyId %d", i));
		if (!enemies[i].dead)		
			return i;
		i++;
	}
	return i;
}

/**
* Find the enemy object 
* @param echar - AGS pointer to enemy character
* @return enemy object ID
*/
short findEnemy(Character *echar)
{
  short i=0;
  while (i < nEnemies)
  {
		if (enemies[i].echar == echar)
			return i;
		i++;
	}
		
}

/**** GUI *********************************************************************************************************************/

function resetMonsterGUI() {
  
	// reset monster gui
	guiMonster2.Visible = false;
  lblMonsterHealth2.Visible = false;
	guiMonster3.Visible = false;
  lblMonsterHealth3.Visible = false;
	guiMonster4.Visible = false;
  lblMonsterHealth4.Visible = false;
	guiMonster5.Visible = false;
  lblMonsterHealth5.Visible = false;
}

function hideCombatInterface()
{
	gMonsterbox.Visible = false;
	gStats.Visible = false;
	gCombatbox.Visible = false;
	

  resetMonsterGUI();
}

function UpdateCombatLabels() {
  
  //if (combatmonster == null) return;
  
 	float h;
	h = (IntToFloat(heroinfo.hp) / IntToFloat(heroinfo.mhp)) * 100.0;
 	lblHealth.NormalGraphic = SetBarGraphic(h);

	int aliveEnemyId = getFirstAliveEnemyId();
	if (aliveEnemyId == nEnemies)
		return;

 	//lblMonsterLabel.Text = combatmonster.Name;
 	
 	h = (IntToFloat(heroinfo.sp) / IntToFloat(heroinfo.msp)) * 100.0;
 	lblStaminaBar.NormalGraphic = SetBarGraphic(h);
 	
 	// monster labels
	//h = (IntToFloat(enemies[aliveEnemyId].hp) / IntToFloat(enemies[aliveEnemyId].mhp)) * 100.0;
	h = (IntToFloat(enemies[0].hp) / IntToFloat(enemies[0].mhp)) * 100.0;
 	lblMonsterHealth.NormalGraphic = SetBarGraphic(h);
 	
 	if (nEnemies >= 2) {
		h = (IntToFloat(enemies[1].hp) / IntToFloat(enemies[1].mhp)) * 100.0;
		lblMonsterHealth2.NormalGraphic = SetBarGraphic(h);
	}
 	if (nEnemies >= 3) {
		h = (IntToFloat(enemies[2].hp) / IntToFloat(enemies[2].mhp)) * 100.0;
		lblMonsterHealth3.NormalGraphic = SetBarGraphic(h);
	}	
 	if (nEnemies >= 4) {
		h = (IntToFloat(enemies[3].hp) / IntToFloat(enemies[3].mhp)) * 100.0;
		lblMonsterHealth4.NormalGraphic = SetBarGraphic(h);
	}
 	if (nEnemies >= 5) {
		h = (IntToFloat(enemies[4].hp) / IntToFloat(enemies[4].mhp)) * 100.0;
		lblMonsterHealth5.NormalGraphic = SetBarGraphic(h);
	}	
}

/**
* Update GUI during combat
*/
function updCCombatGUI()
{
	cCriticaltext.Transparency = minInt(cCriticaltext.Transparency + 1, 100);
	UpdateCombatLabels();
}

/**** Initialization *****************************************************************************************************/

// todo - initialize other enemy types here
function initEnemyTypes()
{
	short i = 0;

	enemyTypes[EnType_Hobgoblin].id = 5;
	enemyTypes[EnType_Hobgoblin].name = "Hobgoblin";
	enemyTypes[EnType_Hobgoblin].anmWalk = 9;
	enemyTypes[EnType_Hobgoblin].anmCombat = 10; 
	enemyTypes[EnType_Hobgoblin].hp = 25;
	enemyTypes[EnType_Hobgoblin].mhp = 25;
	enemyTypes[EnType_Hobgoblin].mp = 0;
	enemyTypes[EnType_Hobgoblin].mmp = 0;
	enemyTypes[EnType_Hobgoblin].str = 20;
	enemyTypes[EnType_Hobgoblin].agi = 20;
	enemyTypes[EnType_Hobgoblin].dodge = 20;
	enemyTypes[EnType_Hobgoblin].luck = 20;
	enemyTypes[EnType_Hobgoblin].weaponuse = 25;
	enemyTypes[EnType_Hobgoblin].dmgtype = 0;
	enemyTypes[EnType_Hobgoblin].mindmg = 2;
	enemyTypes[EnType_Hobgoblin].maxdmg = 8;
	enemyTypes[EnType_Hobgoblin].armor = 20;
	enemyTypes[EnType_Hobgoblin].hitFrame1 = 6;
	enemyTypes[EnType_Hobgoblin].hitFrame2 = 0;
	enemyTypes[EnType_Hobgoblin].hitFrame3 = 0;
	enemyTypes[EnType_Hobgoblin].gold = 0;
	enemyTypes[EnType_Hobgoblin].silver = 15;
	enemyTypes[EnType_Hobgoblin].walkSpeed = 6;
	enemyTypes[EnType_Hobgoblin].anmSpeed = 2;

	enemyTypes[EnType_ShadowMage].id = 3;
	enemyTypes[EnType_ShadowMage].name = "Shadow Mage";
	enemyTypes[EnType_ShadowMage].anmWalk = 7;
	enemyTypes[EnType_ShadowMage].anmCombat = 8; 
	enemyTypes[EnType_ShadowMage].hp = 60;
	enemyTypes[EnType_ShadowMage].mhp = 60;
	enemyTypes[EnType_ShadowMage].mp = 0;
	enemyTypes[EnType_ShadowMage].mmp = 0;
	enemyTypes[EnType_ShadowMage].str = 45;
	enemyTypes[EnType_ShadowMage].agi = 20;
	enemyTypes[EnType_ShadowMage].dodge = 20;
	enemyTypes[EnType_ShadowMage].luck = 50;
	enemyTypes[EnType_ShadowMage].weaponuse = 40;
	enemyTypes[EnType_ShadowMage].dmgtype = 0;
	enemyTypes[EnType_ShadowMage].mindmg = 4;
	enemyTypes[EnType_ShadowMage].maxdmg = 15;
	enemyTypes[EnType_ShadowMage].armor = 45;
	enemyTypes[EnType_ShadowMage].hitFrame1 = 6;
	enemyTypes[EnType_ShadowMage].hitFrame2 = 0;
	enemyTypes[EnType_ShadowMage].hitFrame3 = 0;
	enemyTypes[EnType_ShadowMage].gold = 0;
	enemyTypes[EnType_ShadowMage].silver = 0;
	enemyTypes[EnType_ShadowMage].walkSpeed = 5;
	enemyTypes[EnType_ShadowMage].anmSpeed = 1;
  
	enemyTypes[EnType_ClayGolem].id = 12;
	enemyTypes[EnType_ClayGolem].name = "Clay Monster";
	enemyTypes[EnType_ClayGolem].anmWalk = 18;
	enemyTypes[EnType_ClayGolem].anmCombat = 20; 
	enemyTypes[EnType_ClayGolem].hp = 60;
	enemyTypes[EnType_ClayGolem].mhp = 60;
	enemyTypes[EnType_ClayGolem].mp = 0;
	enemyTypes[EnType_ClayGolem].mmp = 0;
	enemyTypes[EnType_ClayGolem].str = 45;
	enemyTypes[EnType_ClayGolem].agi = 20;
	enemyTypes[EnType_ClayGolem].dodge = 20;
	enemyTypes[EnType_ClayGolem].luck = 50;
	enemyTypes[EnType_ClayGolem].weaponuse = 40;
	enemyTypes[EnType_ClayGolem].dmgtype = 0;
	enemyTypes[EnType_ClayGolem].mindmg = 4;
	enemyTypes[EnType_ClayGolem].maxdmg = 15;
	enemyTypes[EnType_ClayGolem].armor = 45;
	enemyTypes[EnType_ClayGolem].hitFrame1 = 3;
	enemyTypes[EnType_ClayGolem].hitFrame2 = 0;
	enemyTypes[EnType_ClayGolem].hitFrame3 = 0;
	enemyTypes[EnType_ClayGolem].gold = 0;
	enemyTypes[EnType_ClayGolem].silver = 0;
	enemyTypes[EnType_ClayGolem].walkSpeed = 3;
	enemyTypes[EnType_ClayGolem].anmSpeed = 2;

	enemyTypes[EnType_WoodGolem].id = 13;
	enemyTypes[EnType_WoodGolem].name = "Clay Monster";
	enemyTypes[EnType_WoodGolem].anmWalk = 19;
	enemyTypes[EnType_WoodGolem].anmCombat = 21; 
	enemyTypes[EnType_WoodGolem].hp = 50;
	enemyTypes[EnType_WoodGolem].mhp = 50;
	enemyTypes[EnType_WoodGolem].mp = 0;
	enemyTypes[EnType_WoodGolem].mmp = 0;
	enemyTypes[EnType_WoodGolem].str = 35;
	enemyTypes[EnType_WoodGolem].agi = 25;
	enemyTypes[EnType_WoodGolem].dodge = 20;
	enemyTypes[EnType_WoodGolem].luck = 10;
	enemyTypes[EnType_WoodGolem].weaponuse = 50;
	enemyTypes[EnType_WoodGolem].dmgtype = 0;
	enemyTypes[EnType_WoodGolem].mindmg = 10;
	enemyTypes[EnType_WoodGolem].maxdmg = 25;
	enemyTypes[EnType_WoodGolem].armor = 25;
	enemyTypes[EnType_WoodGolem].hitFrame1 = 6;
	enemyTypes[EnType_WoodGolem].hitFrame2 = 0;
	enemyTypes[EnType_WoodGolem].hitFrame3 = 0;
	enemyTypes[EnType_WoodGolem].gold = 0;
	enemyTypes[EnType_WoodGolem].silver = 0;
	enemyTypes[EnType_WoodGolem].walkSpeed = 5;
	enemyTypes[EnType_WoodGolem].anmSpeed = 1;

	enemyTypes[EnType_Rogue].id = 14;
	enemyTypes[EnType_Rogue].name = "Rogue";
	enemyTypes[EnType_Rogue].anmWalk = 22;
	enemyTypes[EnType_Rogue].anmCombat = 23; 
	enemyTypes[EnType_Rogue].hp = 40;
	enemyTypes[EnType_Rogue].mhp = 40;
	enemyTypes[EnType_Rogue].mp = 0;
	enemyTypes[EnType_Rogue].mmp = 0;
	enemyTypes[EnType_Rogue].str = 30;
	enemyTypes[EnType_Rogue].agi = 20;
	enemyTypes[EnType_Rogue].dodge = 40;
	enemyTypes[EnType_Rogue].luck = 15;
	enemyTypes[EnType_Rogue].weaponuse = 30;
	enemyTypes[EnType_Rogue].dmgtype = 0;
	enemyTypes[EnType_Rogue].mindmg = 5;
	enemyTypes[EnType_Rogue].maxdmg = 10;
	enemyTypes[EnType_Rogue].armor = 20;
	enemyTypes[EnType_Rogue].hitFrame1 = 6;
	enemyTypes[EnType_Rogue].hitFrame2 = 4;
	enemyTypes[EnType_Rogue].hitFrame3 = 0;
	enemyTypes[EnType_Rogue].gold = 2;
	enemyTypes[EnType_Rogue].silver = 8;
	enemyTypes[EnType_Rogue].walkSpeed = 6;
	enemyTypes[EnType_Rogue].anmSpeed = 2;

	enemyTypes[EnType_Boggle].id = 15;
	enemyTypes[EnType_Boggle].name = "Boggle";
	enemyTypes[EnType_Boggle].anmWalk = 25;
	enemyTypes[EnType_Boggle].anmCombat = 26; 
	enemyTypes[EnType_Boggle].hp = 40;
	enemyTypes[EnType_Boggle].mhp = 40;
	enemyTypes[EnType_Boggle].mp = 0;
	enemyTypes[EnType_Boggle].mmp = 0;
	enemyTypes[EnType_Boggle].str = 20;
	enemyTypes[EnType_Boggle].agi = 20;
	enemyTypes[EnType_Boggle].dodge = 15;
	enemyTypes[EnType_Boggle].luck = 25;
	enemyTypes[EnType_Boggle].weaponuse = 50;
	enemyTypes[EnType_Boggle].dmgtype = 0;
	enemyTypes[EnType_Boggle].mindmg = 2;
	enemyTypes[EnType_Boggle].maxdmg = 20;
	enemyTypes[EnType_Boggle].armor = 25;
	enemyTypes[EnType_Boggle].hitFrame1 = 7;
	enemyTypes[EnType_Boggle].hitFrame2 = 0;
	enemyTypes[EnType_Boggle].hitFrame3 = 0;
	enemyTypes[EnType_Boggle].gold = 0;
	enemyTypes[EnType_Boggle].silver = 0;
	enemyTypes[EnType_Boggle].walkSpeed = 5;
	enemyTypes[EnType_Boggle].anmSpeed = 2;

	enemyTypes[EnType_Drake].id = 25;
	enemyTypes[EnType_Drake].name = "Drake";
	enemyTypes[EnType_Drake].anmWalk = 48;
	enemyTypes[EnType_Drake].anmCombat = 49; 
	enemyTypes[EnType_Drake].hp = 35;
	enemyTypes[EnType_Drake].mhp = 35;
	enemyTypes[EnType_Drake].mp = 0;
	enemyTypes[EnType_Drake].mmp = 0;
	enemyTypes[EnType_Drake].str = 15;
	enemyTypes[EnType_Drake].agi = 20;
	enemyTypes[EnType_Drake].dodge = 15;
	enemyTypes[EnType_Drake].luck = 1;
	enemyTypes[EnType_Drake].weaponuse = 20;
	enemyTypes[EnType_Drake].dmgtype = 0;
	enemyTypes[EnType_Drake].mindmg = 1;
	enemyTypes[EnType_Drake].maxdmg = 9;
	enemyTypes[EnType_Drake].armor = 1;
	enemyTypes[EnType_Drake].hitFrame1 = 4;
	enemyTypes[EnType_Drake].hitFrame2 = 0;
	enemyTypes[EnType_Drake].hitFrame3 = 0;
	enemyTypes[EnType_Drake].gold = 0;
	enemyTypes[EnType_Drake].silver = 0;
	enemyTypes[EnType_Drake].walkSpeed = 5;
	enemyTypes[EnType_Drake].anmSpeed = 2;

	// init dummy chars list
	dummyChars[0] = cEnemy1;
	dummyChars[1] = cEnemy2;
	dummyChars[2] = cEnemy3;
	dummyChars[3] = cEnemy4;
	dummyChars[4] = cEnemy5;
}
	
	
/**** Hero *************************************************************************************************************/

function DecreaseStamina(short val) {
	heroinfo.sp -= val;

	if (heroinfo.sp < 0) {
		// charge overused stamina to health
		//heroinfo.hp = heroinfo.hp + heroinfo.sp
		heroinfo.sp = 0;
		//cmbhero.state = 0;
		// give warning
		//TODO: I'm gonna just stop them from doing anything for now, instead of killing the hero...this will require the hero to dodge some attacks.
		//Display("The slightest physical effort causes your body great pain. You need rest now.");
	}

}

function DecreaseHealth(short val) {
	heroinfo.hp -= val;

	if (heroinfo.hp <= 0) {
		heroinfo.hp = 0;
		//Display("game over");
		//heroinfo.hp = heroinfo.mhp;
	}
}  


bool isHeroInCombat()
{
	if (heroInCombat)
		return true;
	else
		return false;
}		

bool isHeroDefeated()
{
  return defeatedInCombat;
}

bool IsHeroAttacking() {
  if (cEgo.Animating && cEgo.View == HERO_COMBAT) {
    if (cEgo.Loop == CbAnim_Attack1 || cEgo.Loop == CbAnim_Attack2 || cEgo.Loop == CbAnim_Attack3) { 
      return true;
    }
  }
  return false;
}

bool IsHeroBlocking() {
  if (cEgo.Animating && cEgo.View == HERO_COMBAT) {
    if (cEgo.Loop == CbAnim_Block) { 
      return true;
    }
  }
  return false;
}

bool IsHeroDodging() {
  if (cEgo.Animating && cEgo.View == HERO_COMBAT) {
    if (cEgo.Loop == CbAnim_Dodge) { 
      return true;
    }
  }
  return false;
}

bool IsHeroFlinching() {
  if (cEgo.Animating && cEgo.View == HERO_COMBAT) {
    if (cEgo.Loop == CbAnim_Flinch) 
	   return true;
  }
  return false;
}


/**** Damage/stats calculation  *******************************************************************************************************/


// todo - this must be balanced

short calcHeroHitProb()
{
// actually... for to_hit, the max value possible is 195 given 100 max value for each stat
	//not really working: to_hit = math.max(195,heroinfo.weaponuse/2 + obj_from.agi/2 + obj_from.str/4 + Random(1, obj_from.luck)/2 + Random(1,20))
	float temp = IntToFloat(heroinfo.weaponuse)/2.0 + IntToFloat(heroinfo.agi)/2.0 + IntToFloat(heroinfo.str)/4.0 + (IntToFloat(Random(heroinfo.luck))/2.0) + (IntToFloat(Random(20)+1));
	short to_hit = FloatToInt(min(temp, 195.0));
	//not really working: dodge  = math.max(160, obj_to.dodge/2 + obj_to.agi/5 + Random(1,obj_to.luck)/10)  
	
	return to_hit;
}

short calcHeroDamage()
{
		short weapon_dmg = 0;
		//if (heroinfo.i_weapon!=0) {
		//	weapon_dmg = heroinfo.i_weapon.dmg;
		//}

		short damage = FloatToInt(IntToFloat(heroinfo.weaponuse)/5.0 + IntToFloat(heroinfo.str)/10.0 + IntToFloat(weapon_dmg) );
		// Account for type of attack
		//damage *= ((cmbhero.attacktype+1) / 3)
		//damage = FloatToInt(IntToFloat(damage) * IntToFloat((cEgo.Loop-1) / 3));
		damage = FloatToInt(IntToFloat(damage) * (IntToFloat(cEgo.Loop-1) / 3.0));
		//Display("%d", damage);
		
		return damage;
}

short calcHeroParry()
{
	float temp  = IntToFloat(heroinfo.parry)/2.0 + IntToFloat(heroinfo.agi)/4.0 + IntToFloat(heroinfo.str)/10.0 + IntToFloat(Random(heroinfo.luck))/2.0;
	short parry = FloatToInt(min(160.0, temp));
	
	return parry;
  
}

short calcHeroDodge()
{
	float temp  = IntToFloat(heroinfo.dodge)/2.0 + IntToFloat(heroinfo.agi)/3.0 + IntToFloat(Random(heroinfo.luck))/2.0 + IntToFloat(Random(8))+1.0;
	short dodge = FloatToInt(min(180.0, temp));
	
	return dodge;
  
}

/**
* Check if current hero attack is critical
*/
bool isHeroCriticalAttack()
{
	short rval = Random(100)+1;
	
	// 5% base chance for critical + bonus agi/4	
	if (rval > (95 - heroinfo.agi/4))
		return true;
	else 
		return false;  
}


/**** Combat hero actions *****************************************************************************************************/

function HeroAttack(short attacktype) {
	if (cEgo.Animating) return;
	// play sound effect, use stamina
	// TODO: Reverse the stamina costs, since it takes more effort to move faster? Perhaps just equalize them...they're already close...
	
	if (attacktype == 0) {
		// thrust
		cEgo.Animate(CbAnim_Attack1, 3,eOnce,eNoBlock);
		DecreaseStamina(Random(1)+1);
		//swordthrust:Play(0) 
	}
  
	else if (attacktype == 1) {
  		// slash
		cEgo.Animate(CbAnim_Attack2, 3,eOnce,eNoBlock);
		DecreaseStamina(Random(2)+1);
		//swordswoosh:Play(0)	  
	}

	else if (attacktype == 2) {
		// slow: slice
		cEgo.Animate(CbAnim_Attack3, 3,eOnce,eNoBlock);
  		DecreaseStamina(Random(3)+2);
	  //swordswoosh:Play(0)  
  }

}

// Hero blocks/dodges an attack
function HeroBlock(short blocktype) {
	if (cEgo.Animating) return;

	if (blocktype==0) {
	//DecreaseStamina(0); -- can always lift shield up...
   	cEgo.Animate(CbAnim_Block, 3,eOnce,eNoBlock);
  }
	else if (blocktype==1) {
		cEgo.Animate(CbAnim_Dodge, 3,eOnce,eNoBlock);
		DecreaseStamina(Random(2)+1);
  }
}

/**
* Hero gets hurt
*/
function heroFlinch()
{
	cEgo.Loop = CbAnim_Flinch;
	cEgo.Animate(CbAnim_Flinch, 3, eOnce, eNoBlock, eForwards);
	PlaySound(5);
	PlaySound(6);  
}



/**** Enemy  *************************************************************************************************************/

/**
* @return if a enemy is attacking
* @param enemy - pointer to an AGS character 
*/
bool Enemy::isAttacking() {

	Character* echar = this.echar;
	if (echar.Animating && echar.View == this.anmCombat) {
		if (echar.Loop == ECbAnim_Attack1 || echar.Loop == ECbAnim_Attack2 || echar.Loop == ECbAnim_Attack3)
			return true;
	}

	return false;
}

/**
* @return if a enemy is flinching
* @param enemy - pointer to an AGS character 
*/
bool Enemy::isFlinching() {
  
  Character* echar = this.echar;
  if (echar.Animating && echar.View == this.anmCombat) {
    if (echar.Loop == ECbAnim_Flinch) return true;
  }
  return false;
}

/**
* @return if a enemy is blocking
* @param enemy - pointer to an AGS character 
*/
bool Enemy::isBlocking() {
  
	Character* echar = this.echar;
  if (echar.Animating && echar.View == this.anmCombat) {
    if (echar.Loop == ECbAnim_Block) return true;
  }
  return false;
}

/**
* @return enemy hit probability
* Calculated for each own attack
*/
short Enemy::calcHitProb(){
			
	float temp = IntToFloat(this.weaponuse)/2.0 + IntToFloat(this.agi)/4.0 + IntToFloat(this.str)/8.0 + IntToFloat(Random(this.luck))/10.0;
	short to_hit = FloatToInt(min(195.0,temp));
	return to_hit;
}

/**
* @return enemy attack damage
* Calculated for each own attack
*/
short Enemy::calcDamage()
{
  short damage;
	
	damage = FloatToInt(IntToFloat(Random(this.maxdmg) + this.mindmg) + IntToFloat(this.weaponuse)/10.0 + IntToFloat(this.str)/20.0);
 
 	// Account for monster attack type.
	if (this.echar.Loop == ECbAnim_Attack2) {
		damage = damage / 2 + 1;
	}
	else if (this.echar.Loop == ECbAnim_Attack3) {
		damage = damage / 3 + 1;
	}

	return damage;
}

/**
* @return enemy dodge 
* Calculated for each hero attack
*/
short Enemy::calcDodge()
{
  float dodgeStat = IntToFloat(this.dodge);
	float agiStat = IntToFloat(this.agi);
	float rdluckStat = IntToFloat(Random(this.luck)+1);
	
	float temp   = dodgeStat/2.0 + agiStat/5.0 + rdluckStat/10.0;
	short dodge  = FloatToInt(min(temp, 160.0) + IntToFloat(Random(20)+1));
  
  return dodge;
}

/**
* Enemy starts to defend/dodge an attack
*/
function Enemy::Defend()
{
	this.echar.Animate(ECbAnim_Block, 2, eOnce, eNoBlock, eForwards);
}

/**
* Enemy becomes idle
*/
function Enemy::BeIdle()
{
	this.echar.Animate(ECbAnim_Idle, 3, eRepeat, eNoBlock, eForwards);
}

/**
* Enemy dies
*/
function Enemy::Die()
{
	PlaySound(1);
	this.echar.Animate(ECbAnim_Death, 3, eOnce, eNoBlock, eForwards);
	
	this.dead = 1;  
	this.echar.Solid = false;
}

/**
* Enemy gets hurt
*/
function Enemy::Flinch()
{
	this.echar.Animate(ECbAnim_Flinch, 3, eOnce, eNoBlock, eForwards);
	PlaySound(2);
	PlaySound(4);
}

// Inflict damage to the hero
short Enemy::InflictDamageToHero() {
	short damage, hitProb, dodge, parry;
	dodge = 0; 
	parry = 0;
  
	// calc enemy damage and hit probability
	damage = this.calcDamage();
	hitProb = this.calcHitProb();
	//Display("%d", damage);
	
	// increase stats by minimum	
	IncreaseLuckStat(1);
	IncreaseIntelligenceStat(1);

	// Account for dodge/parry
	if (IsHeroBlocking()) {
	  parry = calcHeroParry();
		dodge = parry;
	}
	else if (IsHeroDodging()) {
		dodge = calcHeroDodge();
	} 
		
	// TODO::Account for shield type...

	// if dodge/parry is successful,damage=0 and increase stats
	if (Random(hitProb)+1 < Random(dodge)+1) { //) {
		damage = 0;

		if (parry != 0) {
			// parry
			// increase parry and weapon use stats
			IncreaseParryStat(Random(4)+4 + floor(IntToFloat(parry)/3.0));
			IncreaseWeaponUseStat(Random(3)+2);
		}
		else {
			// dodge
			// increase dodge stat
			IncreaseDodgeStat(Random(4)+4 + floor(IntToFloat(dodge)/3.0));
		}
		// increase luck, agility and intelligence stats
		IncreaseLuckStat(Random(5)+5);
		IncreaseAgilityStat(Random(6)+6);
		IncreaseIntelligenceStat(Random(4)+2);
	}
	// if dodge//parry fails
	else if (dodge != 0) { 
		// dodge attempt reduces some damage? No.

		//damage = damage * (dodge / (to_hit)) / 2

		if (parry!=0) {
			// parry
			//BlockFailed_Effects()	
	 }		
		else {
			// block
			//DodgeFailed_Effects()
		}
	}

	// restrict damage to [0, HP] and deduct from hero HP
	if (damage >= heroinfo.hp) {
		// dead!
		damage = heroinfo.hp;
	}
	else if (damage < 0) {
		damage = 0;
	}
	
	// todo - uncomment this after test
	//DecreaseHealth(damage);


	return damage;
}


// Inflict damage from the hero
short Enemy::InflictDamageFromHero() {
	
	if (this.isBlocking()) return 0;
	
	short hitProb, damage, dodge;

	hitProb = calcHeroHitProb();	
	dodge = this.calcDodge();
	damage = 0;
  
	// TODO: USE ARMOR TO ABSORB DAMAGE???
	// if we hit the monster, calculate damage
	if (Random(hitProb)+1 >= Random(dodge)+1) {
	//if (HeroWillHit) {
		damage = calcHeroDamage();

		// increase strength stat with a little bonus from inflicted damage
		IncreaseStengthStat(Random(4)+6 + (damage/4) + (this.str/3));

		// increase intelligence, agility, vitality and weapon use stats
		IncreaseIntelligenceStat(Random(2)+1 + (damage/5));
		IncreaseAgilityStat(Random(5)+4 + (this.agi/4));
		IncreaseVitalityStat(Random(6)+7 + (this.str/3));
		IncreaseWeaponUseStat(Random(7)+5 + (this.agi/4));

		// Roll for critical...
		if (isHeroCriticalAttack()) {
			//damage = FloatToInt(max(IntToFloat(damage * 2), IntToFloat(damage) * (IntToFloat(heroinfo.str)/20.0)));
			damage = damage * 2;
			// critical bonus is between 2x and 5x, 
			cCriticaltext.Transparency = 0;
		}
	}
	else if (dodge != 0) { 
	  // YOU MISSED!!
		damage = 0;
	}

	// limit damage
	if (damage > this.hp) 
		damage = this.hp;
	else if (damage < 0) 
		damage = 0;

	this.hp -= damage;	
	return damage;
}


/**
* Enemy starts to attack hero
*/
function Enemy::Attack()
{
	short noAttacks = 1;
	if (this.hitFrame2 > 0) 
		noAttacks++;
	
	if (noAttacks == 1) {
		this.echar.Animate(ECbAnim_Attack1,  3, eOnce, eNoBlock, eForwards);
	}
	else {
		// todo - there will be an attack3 for someone?
		short f = Random(noAttacks-1);
		if (f == 0) this.echar.Animate(ECbAnim_Attack1,  3, eOnce, eNoBlock, eForwards);
		else if (f == 1) this.echar.Animate(ECbAnim_Attack2,  3, eOnce, eNoBlock, eForwards);
		else if (f == 2) this.echar.Animate(ECbAnim_Attack3,  3, eOnce, eNoBlock, eForwards);
	}

	PlaySound(7);	
	SetTimer(1, 120);

}


/**
* Monster reacts to an attack
*/
function Enemy::ReactAttack()
{
  short damage = this.InflictDamageFromHero();    
  //this.hp -= damage;
	
	// monster flinch
	if (damage > 0)
	{
		if (this.hp == 0)
		{
			Display("Enemy Die");
			this.Die();
		}
		else
			this.Flinch();
	}

}

/**
* Update an enemy artificial intelligence
*/
function Enemy::updateAI() {
  
	// can't double-attack or attack while flinching/blocking
	if (this.isAttacking()) return; 
	if (this.isFlinching()) return; 
	if (this.isBlocking()) return;	
  
	// Force an attack for waiting so long
	if (IsTimerExpired(1) == 1)
		this.Attack();

	short stayidle = Random(100);
	if (stayidle < 3) {
		// monster will do something
		short defend = Random(100); 
		// if the hero is attacking, then half the time defend
		if ((!IsHeroAttacking() || defend < 50) && !IsHeroFlinching()) {
			// attack!			
			this.Attack();
		}
		else if (IsHeroAttacking()) {
			// defend!
			this.Defend();
		}
	}				
}

/**
* Update enemy animation during combat
*/
function Enemy::updCCombat()
{
	// update AI
	this.updateAI();

	// check if hero must react to attacks
	Character* echar = this.echar;	
	if (echar.Animating && !enemyHitHero) {
		
		if ((echar.Loop == ECbAnim_Attack1 && echar.Frame >= this.hitFrame1) || 
		    (echar.Loop == ECbAnim_Attack2 && echar.Frame >= this.hitFrame2) )
		{
			short damage = this.InflictDamageToHero();
			if (damage > 0)
				if (heroinfo.hp > 0) 
					heroFlinch();
			
			enemyHitHero = true;
	  }

	}

	// go idle if doing nothing
	if (!echar.Animating) {
		this.BeIdle();
		enemyHitHero = false;
	}

}

function Enemy::updFollowHero()
{
	Character* echar = this.echar;
	echar.Walk(cEgo.x, cEgo.y, eNoBlock, eWalkableAreas);
	if (!IsCharacterWithinRoomBounds(echar)) {
	  Display("stuck!");
	  //echar.Walk(160, 160, eNoBlock, eAnywhere);
	if (echar.x > 300) {
		echar.x = 340;
		echar.Walk(310, echar.y, eNoBlock, eAnywhere);
	}
	else if (echar.x < 20) {
		echar.x = -20;
		echar.Walk(10, echar.y, eNoBlock, eAnywhere);
	}
	else if (echar.y > 220) {
		echar.y = 310;
		echar.Walk(echar.x, 230, eNoBlock, eAnywhere);
	}	  
	}

}

function Enemy::updFollowHeroNewRoom()
{
	Character* echar = this.echar;

	echar.ChangeRoom(cEgo.Room);
  
	if (echar.x > 300) {
		echar.x = 340;
		echar.Walk(310, echar.y, eNoBlock, eAnywhere);
	}
	else if (echar.x < 20) {
		echar.x = -20;
		echar.Walk(10, echar.y, eNoBlock, eAnywhere);
	}
	else if (echar.y > 220) {
		echar.y = 310;
		echar.Walk(echar.x, 230, eNoBlock, eAnywhere);
	}
		
		//enemy.FollowCharacter(cEgo, 0, 0);
}

function Enemy::updFCombat()
{
	if (this.hp <= 0) { 
		this.echar.FollowCharacter(null);
		this.echar.LockView(this.anmCombat);

		this.Die();
		
		heroInCombat = false;
	}
}


/**
* Monster stops chasing the hero
*/
function StopMonsterChasing(Character *enemy) {
  
  // stop any monster from chasing you and deletes them
	if (enemy != null)
		enemy.ChangeRoom(-1);
	enemy = null;
}

function giveMoney(int gold, int silver)
{
 	heroinfo.gold += gold;
	heroinfo.silver += silver;
}

function Enemy::genericUse()
{
	// Generic Monster will randomly select an amount of gold to give to hero...
	if (this.searched) {
	  Display("You already searched this creature");
	  return;
	}

  short getgold, getsilver;
	cEgo.Walk(this.echar.x,  this.echar.y, eBlock, eWalkableAreas);
	cEgo.LockView(HERO_PICKUP);
	cEgo.Animate(2, 2, eOnce, eBlock, eForwards);
	cEgo.LockView(GetModeView());
	getgold = Random(this.gold);
	getsilver = Random(this.silver);
	if (getgold==0 && getsilver==0) {
		Display("You search the body but nothing of any value is found.");
	}
	else if (getgold!=0 && getsilver!=0) {
		Display("After searching the body, you find %d gold and %d silver pieces.", getgold, getsilver);
	}
	else if (getgold==0) {
		Display("After searching the body, you find %d silver pieces.", getsilver);
  }
	else if (getsilver==0) {
		Display("After searching the body, you find %d gold pieces.", getgold);	
	}
	// Give hero the loot
	giveMoney(getgold,  getsilver);

  if (flags.GreenleafFavor == 1 && heroinfo.class == CLASS_FIGHTER &&
			this.type == EnType_Hobgoblin && cEgo.InventoryQuantity[iGoblinTeeth.ID] == 0) 
	{
    Display("Holding your nose to avoid the foul smell, you withdraw seven of the dead hobgoblins damaged teeth and take them with you. You hope you don't make a habit of this.");
    cEgo.AddInventory(iGoblinTeeth);
  }

  this.searched = true; // disable future searching
  
  
}

function GenericMonsterUse(Character* echar) {

	int id = findEnemy(echar);
	enemies[id].genericUse();
}



/**** Far combat ************************************************************************************************************/

/**
* Initialize a new enemy
* @param enemyId - enemy type id
* @return true if created, false otherwise
*
* enemyType is the enemy "race" , hobgoblin, rogue, etc... 
* enemyID is the Enemy position in the enemies array
*
*/
bool newEnemy(int enemyType, int enemyId)
{
	// check if it's a valid enemyId
	if (enemyId < 0 || enemyId > MAX_ENEMIES-1)
		return false;
	
	// check if it's a valid enemyType
	if (enemyType < 0 || enemyType > EnType_Max - 1)
	{
		return false;
	}

	//if (nEnemies < MAX_ENEMIES)
	//	nEnemies++;

	enemies[enemyId].echar = dummyChars[enemyId];
	enemies[enemyId].type = enemyType;

	enemies[enemyId].id = enemyTypes[enemyType].id;
	enemies[enemyId].name = enemyTypes[enemyType].name;
	enemies[enemyId].anmWalk = enemyTypes[enemyType].anmWalk;
	enemies[enemyId].anmCombat = enemyTypes[enemyType].anmCombat; 
	enemies[enemyId].hp = enemyTypes[enemyType].hp;
	enemies[enemyId].mhp = enemyTypes[enemyType].mhp;
	enemies[enemyId].mp = enemyTypes[enemyType].mp;
	enemies[enemyId].mmp = enemyTypes[enemyType].mmp;
	enemies[enemyId].str = enemyTypes[enemyType].str;
	enemies[enemyId].agi = enemyTypes[enemyType].agi;
	enemies[enemyId].dodge = enemyTypes[enemyType].dodge;
	enemies[enemyId].luck = enemyTypes[enemyType].luck;
	enemies[enemyId].weaponuse = enemyTypes[enemyType].weaponuse;
	enemies[enemyId].dmgtype = enemyTypes[enemyType].dmgtype;
	enemies[enemyId].mindmg = enemyTypes[enemyType].mindmg;
	enemies[enemyId].maxdmg = enemyTypes[enemyType].maxdmg;
	enemies[enemyId].armor = enemyTypes[enemyType].armor;
	enemies[enemyId].hitFrame1 = enemyTypes[enemyType].hitFrame1;
	enemies[enemyId].hitFrame2 = enemyTypes[enemyType].hitFrame2;
	enemies[enemyId].hitFrame3 = enemyTypes[enemyType].hitFrame3;
	enemies[enemyId].gold = enemyTypes[enemyType].gold;
	enemies[enemyId].silver = enemyTypes[enemyType].silver;
	
  enemies[enemyId].echar.SetWalkSpeed(enemyTypes[enemyType].walkSpeed, enemyTypes[enemyType].walkSpeed);
	enemies[enemyId].echar.AnimationSpeed = enemyTypes[enemyType].anmSpeed;
  enemies[enemyId].searched = false;
  
	return true;
	
}

// These handle enemy spawn, hero pursuit and far combat
// TODO - support far combat 

function checkCCombatStart()
{
	if (cEgo.Room != combatRoomId) { 
  		
  	// is hero colliding with an enemy
		short i=0;
		bool flag = true;
		while (i < nEnemies && flag)
		{
			if (!enemies[i].dead)
			{
		 		if (cEgo.IsCollidingWithChar(enemies[i].echar)) 
					flag = false;
			}
			i++;
		}
	
		// if collided, transport change ego and all alive monsters to room
		if (!flag)
		{
			cEgo.ChangeRoom(combatRoomId);
			i = 0;
			while (i < nEnemies)
			{
			  if (!enemies[i].dead)
			  {
					enemies[i].echar.ChangeRoom(combatRoomId);
				}
				i++;
			}
		}

		/*
		monsters startPos

		cGoblin - 164, 184
		cClayGolem - 164, 184
		cWoodgolem - 164, 184
		cRoguemonster - 170, 184
		cBoggle - 164, 184
		cDrake - 184, 181
		*/
	}
  
}

function SpawnFromSouth(Character *m) {
	m.ChangeRoom(cEgo.Room, 160 + Random(30) - 15, Room.BottomEdge);
	m.PlaceOnWalkableArea();
	m.y = 300;
	m.Walk(m.x, Room.BottomEdge - 5, eNoBlock, eAnywhere);
	//CharacterControl.CreateChain(1, String.Format("WALK:%d,%d;", m.x, Room.BottomEdge - 2));
}
function SpawnFromWest(Character *m) {
	m.ChangeRoom(cEgo.Room, Room.LeftEdge, 150 + Random(50) - 25);
	m.PlaceOnWalkableArea();
	m.x = -20;
	m.Walk(Room.LeftEdge + 5, m.y, eNoBlock, eAnywhere);
}
function SpawnFromEast(Character *m) {
	m.ChangeRoom(cEgo.Room, Room.RightEdge, 150 + Random(50) - 25);
	m.PlaceOnWalkableArea();
	m.x = 340;
	m.Walk(Room.RightEdge - 5, m.y, eNoBlock, eAnywhere);
	//CharacterControl.CreateChain(1, String.Format("WALK:%d,%d;", Room.RightEdge - 2, m.y));
}
function SpawnFromNorth(Character *m) {
	m.ChangeRoom(cEgo.Room, 160 + Random(30) - 15, Room.TopEdge);
	m.PlaceOnWalkableArea();
	//m.y = 360;
	//m.Walk(m.x, Room.BottomEdge - 2, eNoBlock, eAnywhere);
}


function SpawnFromExit(Character* echar, short exit) {
  
  /**
  * Select an available room exit to spawn monster from
  * 0 - south,  1 - west,  2 - east, 3 - north
  */
	if (exit == 0 ) {
		// facing south
		if (hasSouthExit()) SpawnFromSouth(echar);
		else if (hasEastExit()) SpawnFromEast(echar);
		else if (hasWestExit()) SpawnFromWest(echar);
	}
	else if (exit == 1 ) {
	  // facing left
		if (hasWestExit()) SpawnFromWest(echar);
		else if (hasSouthExit()) SpawnFromSouth(echar);
		else if (hasNorthExit()) SpawnFromNorth(echar);
	}
	else if (exit == 2 ) {
	  // facing right
		if (hasEastExit()) SpawnFromEast(echar);
		else if (hasSouthExit()) SpawnFromSouth(echar);
		else if (hasNorthExit()) SpawnFromNorth(echar);
	}
	else if (exit == 3) {
	  // facing north
		if (hasEastExit()) SpawnFromEast(echar);
		else if (hasWestExit()) SpawnFromWest(echar);
		else if (hasNorthExit()) SpawnFromNorth(echar);
	}
	else {
	  Display("ExitVal=%d Unable to find available exit for monster spawn. Please report this bug.", exit);
	}
	
}

/**
* Create a new enemy to pursuit the hero
*/
function SpawnEnemy(int enemyType, int enemyId) {
  
	
	if (!newEnemy(enemyType, enemyId))
		return;
	heroInCombat = true;

	Character* echar = enemies[enemyId].echar;
	echar.Solid = false;
	
	// select exit to spawn from based on where the hero is facing
  SpawnFromExit(echar, cEgo.Loop);
	
	//m.FollowCharacter(cEgo,0,0);
	SetTimer(Timer_FollowChar, 10);
	echar.ChangeView(enemies[enemyId].anmWalk);
	echar.Baseline = 0;
	//echar.Solid = true;
	//Display("Monster has spawned");

  Display("SpawnEnemy: %d %d", echar.x, echar.y);
	enemies[enemyId].dead = 0;
	enemies[enemyId].hp = enemies[enemyId].mhp;

}

/**
* Create a new monster to pursuit the hero at a given screen position
* @param x,y - pos in which monster will be created
*/
function SpawnEnemyCoords(int enemyType, short x, short y) {
	
	// todo - change this to new enemies array
	/*
   if (combatmonster == null) combatmonster = m;
  
   m.ChangeRoom(cEgo.Room, x,y);
  
	SetTimer(3, 10);
	m.Baseline = 0;
	monsterIsDead = 0;
	enemyHP = m.GetProperty("HP");
	combatmonster.Solid = true;
	*/
	
	int enemyId = nEnemies;
	nEnemies++;
	if (!newEnemy(enemyType, enemyId))
		return;
	heroInCombat = true;

	SetTimer(Timer_FollowChar, 10);

	Character *echar = enemies[enemyId].echar;
	echar.ChangeRoom(cEgo.Room, x,y);
	echar.ChangeView(enemies[enemyId].anmWalk);
	echar.Baseline = 0;
	//echar.Solid = true;

	// todo - check if this is needed
	echar.PlaceOnWalkableArea();
}

int chooseEnemy()
{

	short pick = Random(100);
	

	// TODO: IF CHAPTER 1 THEN ...
	if (GetRoomProperty("Scene Flag") == SCENE_TYPE_ROAD) {
		// determine which monster will appear
		if (isday()==true) {
			//it is daytime
			if (pick < 20) return (EnType_Rogue);
			else if (pick < 40) return (EnType_Rogue);
			else if (pick < 60) return(EnType_Rogue);
			else if (pick < 85) return(EnType_Rogue);
			else if (pick < 100) return(EnType_Rogue);
		}
		else {
			//it is night
			if (pick < 20) return(EnType_ShadowMage);
			else if (pick < 35) return(EnType_Hobgoblin);
			else if (pick < 80) return(EnType_Rogue);
			else if (pick < 100) return(EnType_Hobgoblin);
		}
	}

	else if (GetRoomProperty("Scene Flag") == SCENE_TYPE_N_FOREST) {
		if (isday()==true) {
			//it is daytime
			if (pick < 20)  {
				if ((flags.Chapter == 2 && flags.DolmenQuest >= 2) || flags.Chapter >= 3) 
					return(EnType_ShadowMage);
				else 
					return(EnType_Hobgoblin);
			}
			else if (pick < 40) return(EnType_Hobgoblin);
			else if (pick < 60) return(EnType_Rogue);
			else if (pick < 85) return(EnType_Boggle);
			else if (pick < 100) return(EnType_Drake);
		}
		else {
			//it is night
			if (pick < 20)  {
				if ((flags.Chapter == 2 && flags.DolmenQuest >= 2) || flags.Chapter >= 3) 
					return(EnType_ShadowMage);
				else 
					return(EnType_Hobgoblin);
			}
			else if (pick < 35) return(EnType_Hobgoblin);
			else if (pick < 80) return(EnType_Rogue);
			else if (pick < 100) return(EnType_Boggle);
		}
	}

	else	
		return -1;

}
function SpawnRogues(int enemyType, int enemyId) {
  
	
	if (!newEnemy(enemyType, enemyId))
		return;
	heroInCombat = true;

	Character* echar = enemies[enemyId].echar;
	echar.Solid = false;
	
	// select random exit for ambush
  SpawnFromExit(echar, Random(3));
	
	SetTimer(Timer_FollowChar, 10);
	echar.ChangeView(enemies[enemyId].anmWalk);
	echar.Baseline = 0;
	//echar.Solid = true;

  Display("SpawnRogue: %d %d", echar.x, echar.y);
	enemies[enemyId].dead = 0;
	enemies[enemyId].hp = enemies[enemyId].mhp;

}

function HandleMonsterSpawn() {

	// assure that monster will never spawn when a combat just finished
	if (cEgo.PreviousRoom == combatRoomId) 
		return;

	
		// reset all monster positions
		short i=0;
		while (i < MAX_ENEMIES)
		{
			dummyChars[i].ChangeRoom(-1);
			dummyChars[i].UnlockView();
			i++;
		}

		/*
		cShadowmage.ChangeRoom(-1);
		cGoblin.ChangeRoom(-1);
		//cWoodgolem.ChangeRoom(-1);
		//cClaygolem.ChangeRoom(-1);
		cRoguemonster.ChangeRoom(-1);
		cBoggle.ChangeRoom(-1);
		cDrake.ChangeRoom(-1);

		cShadowmage.UnlockView();
		cGoblin.UnlockView();
		cClaygolem.UnlockView();
		//cWoodgolem.UnlockView();
		cRoguemonster.UnlockView();
		cBoggle.UnlockView();
		cDrake.UnlockView();
		*/
	
	 
	 
	// check if there is an encounter
	short enc	= Random(100);
	if ((isday()==true && enc <= 25) || (isday()==false && enc <= 30)) {
		// yes, encounter
	}
	else {
		// no encounter, exit function
		return;
	}

	int spawnQty = 1 + Random(MAX_ENEMIES-1);
	
	Display("spawnQty: %d", spawnQty);
	i=0; nEnemies = 0;
	int nextEnemy = chooseEnemy();
	while (i < spawnQty)
	{
		
		if (nextEnemy != -1)
		{
		  if (nextEnemy == EnType_Rogue) SpawnRogues(nextEnemy, i);
			else SpawnEnemy(nextEnemy, i);
			nEnemies++;
		}		
		i++;
	}

  
}


/**** Far combat update *******************************************************************************************/


function updateFollowHero()
{
	int id = getFirstAliveEnemyId();
	if (id == nEnemies)
		return;

	Character* echar = enemies[id].echar;
	if (echar.Room == cEgo.Room && IsCharacterWithinRoomBounds(echar) && IsTimerExpired(Timer_FollowChar)==1)
	{
		
		if (currEnemyId == nEnemies)
			currEnemyId = 0;
		short i = currEnemyId; 
		short enemiesPerLoop = 0;
		while (i < nEnemies && enemiesPerLoop < 3)
		{
			if (!enemies[i].dead)
				enemies[i].updFollowHero();
			i++;
			enemiesPerLoop++;
		}
		currEnemyId = i;

		//combatmonster.FollowCharacter(null);
		SetTimer(Timer_FollowChar, 15);
	} 
	//else if (echar.Room == cEgo.Room && !IsCharacterWithinRoomBounds(echar) && IsTimerExpired(Timer_FollowChar)==1) {
	  //Display("Possible stuck monster detected");
	  //echar.Walk(160, 160, eNoBlock, eAnywhere);
	  //SetTimer(Timer_FollowChar, 10);
	//}
	
	if (IsTimerExpired(Timer_FollowCharRooms) == 1) 
	{  
		short i=0;
		while (i < nEnemies)
		{
			if (!enemies[i].dead)
				enemies[i].updFollowHeroNewRoom();
			i++;
		}
	}	
		
		//enemy.FollowCharacter(cEgo, 0, 0);
}

function updateFarCombat()
{
	checkCCombatStart();
	
	// when timer expires, walk to current hero pos
	// todo - check why this and not followChar. It doesnt work right?
	
	// update following hero
	updateFollowHero();

	// update ranged combat
	short i = 0;
	while (i < nEnemies)
	{
		enemies[i].updFCombat();
		i++;
	}

}

/**** onEnterRoom update *******************************************************************************************/

function onEnterRoom_updFollowHero()
{
	int id = getFirstAliveEnemyId();
	Character* echar = enemies[id].echar;

	// if coming from combat screen (run button was pressed)
	if (echar.PreviousRoom == combatRoomId) {
		SetTimer(Timer_FollowChar, 20);
		return;
	}	

	// if coming from a normal screen
	short i = 0;
	while (i < nEnemies)
	{
		enemies[i].echar.FollowCharacter(null);      
		enemies[i].echar.ChangeRoom(-1);
		i++;
	}
      
	// lost beast
	if (cEgo.PreviousRoom != combatRoomId && Random(heroinfo.luck) > (heroinfo.luck - (heroinfo.luck/5))) {
		Display("Your lucky. you lost the beast");
		heroInCombat = false;
	}
	// enemy doesnt follow hero to some rooms
	else if (GetRoomProperty("Scene Flag") == SCENE_TYPE_EXTERIOR || GetRoomProperty("Scene Flag") == SCENE_TYPE_INTERIOR || GetRoomProperty("Scene Flag") == SCENE_TYPE_TOWN) {
		heroInCombat = false;
		nEnemies = 0;
		//i = 0;
		//while (i < MAX_ENEMIES) {
		//  enemies[i].echar = null;
		//  i++;
		//}
		
	}
	// follow timer
	else {
		dist = getEuclideanDistance(cEgo, echar);
		SetTimer(Timer_FollowCharRooms, dist / 2);

		i = 0;
		while (i < nEnemies)
		{
			enemies[i].echar.x = cEgo.x;
			enemies[i].echar.y = cEgo.y;
			i++;
		}
	}
}

function onEnterRoom_updCombat(short room)
{
	// reset noise
	alertLevel = 0.0;
	btnAlertLevelMeter.Value = floor(alertLevel);

	if (room != combatRoomId) 
	{   
	  // only spawn 1 monster ---- todo - change this
		if (!heroInCombat) 
			HandleMonsterSpawn();	 		
		else       
			onEnterRoom_updFollowHero();
	}

	// after combat
	if (cEgo.PreviousRoom == combatRoomId) {
		if (heroInCombat)
		{
		}
		else
		{
			short i=0;
			while (i < nEnemies)
			{
				enemies[i].echar.PlaceOnWalkableArea();
				i++;
			}
		}
    cEgo.PlaceOnWalkableArea();

  }
  
}


/**** Close combat ******************************************************************************************************/

// todo - this should call a global GameOver
function combatGameOver()
{
	cCriticaltext.Transparency = 100;
	Display("game over");
	StopMusic();
}


/**
* End close combat, independent of the result
*/
function endCCombat()
{
	// update GUI
	hideCombatInterface();
	gIconbar.Visible = true;
	gTopbar.Visible = true;
	Mouse.Mode = eModeWalkto;

	// hide critical text
	cCriticaltext.Transparency = 100;

	//	stop combat music
	StopMusic();

}

/**
* Actions taken when close combat is lost
*/
function onCCombatLose()
{
	// you die
	heroCollapse();
  
	endCCombat();

	// game over!
	combatGameOver();

	// debug - bring hero back to life and delete enemy
	cEgo.Loop = 0;  
	cEgo.UnlockView();
	cEgo.ChangeRoom(cEgo.PreviousRoom);
	heroinfo.hp = heroinfo.mhp;
	heroinfo.sp = heroinfo.msp;
	
	short i=0;
	while (i < nEnemies)
	{
		enemies[i].echar.UnlockView();
		enemies[i].echar.ChangeRoom(-1);
		i++;
	}


	// special hack for dolmen quest - REMOVE IN FINAL RELEASE
	// todo - fix this
	/*
	if (combatMonster.id == cShadowmagedolm.ID) {
		flags.DolmenQuest = 1;
	}
	*/

	heroInCombat = false;
	defeatedInCombat = true;
}

/**
* Actions taken when close combat is won
*/
function onCCombatWin()
{
	endCCombat();



	short i=0;
	while (i < nEnemies)
	{
		enemies[i].echar.ChangeRoom(cEgo.PreviousRoom);
		i++;
	}	

	// transport ego to previous room and correct its view
	cEgo.ChangeRoom(cEgo.PreviousRoom);
	cEgo.Loop = 0;  
	cEgo.UnlockView();


	heroInCombat = false;

}

function initCombatRoom()
{
	if (!heroInCombat)
		return;
	
	// position ego
	cEgo.x = 140;
	cEgo.y = 210;

	// scale ego
	//cEgo.ManualScaling = true;
	//cEgo.Scaling = 100;
	cEgo.ManualScaling = false;

	// position and scale monsters
	//combatmonster.ManualScaling = true;
	//combatmonster.Scaling = 100;
	Display(String.Format("initCombatRoom: %d", nEnemies));
	
	short i=0;
	while (i < nEnemies)
	{
		//Display(String.Format("init enemy %d",  i));
		enemies[i].echar.ManualScaling = false;
		//enemies[i].echar.x = 40 + 50 * i;
		enemies[i].echar.x = (Room.Width / (nEnemies+1)) * (i+1);
		enemies[i].echar.y = 160;
		enemies[i].echar.ChangeRoom(combatRoomId);
		enemies[i].echar.LockView(enemies[i].anmCombat);
		enemies[i].echar.Animate(ECbAnim_Idle, 3, eRepeat, eNoBlock, eForwards);
		i++;
	}


}

/**
* Initialize combat
*/
function InitCombat() {

	// monster stops following character
	short i=0;
	while (i < nEnemies)
	{
		enemies[i].echar.FollowCharacter(null);
		enemies[i].echar.StopMoving();
		i++;
	}
  
	initCombatRoom();

	// init critical text
	cCriticaltext.ChangeRoom(cEgo.Room);
	cCriticaltext.Transparency = 100;

	heroHitEnemy = false;
	enemyHitHero = false;
	
	defeatedInCombat = false;

	SetRunningMode(0);
	SetSneakingMode(0);

	Mouse.Mode = eModePointer;

	// todo - check this better
	/*
	if (combatMonster == null) {
	  Display("Null combatmonster variable. Setting to default");
	  combatMonster.echar = cShadowmage;
	  combatMonster.echar.ChangeRoom(102);
	}
	*/


	// view essential GUIs
	gMonsterbox.Visible = true;
	gStats.Visible = true;
	gCombatbox.Visible = true;
	gIconbar.Visible = false;
	gTopbar.Visible = false;
	
	resetMonsterGUI();

  // extend monster interface as necessary:
  if (nEnemies >= 2) {
    guiMonster2.Visible = true;
    lblMonsterHealth2.Visible = true;
	}
  if (nEnemies >= 3) {
    guiMonster3.Visible = true;
    lblMonsterHealth3.Visible = true;
	}
  if (nEnemies >= 4) {
    guiMonster4.Visible = true;
    lblMonsterHealth4.Visible = true;
	}
  if (nEnemies >= 5) {
    guiMonster5.Visible = true;
    lblMonsterHealth5.Visible = true;
	}

	// set hero weapon view
	if (cEgo.InventoryQuantity[iLongSword.ID] && heroinfo.class == FIGHTER) {
	  cEgo.LockView(heroCombatView);
	}
	else if (cEgo.InventoryQuantity[iDagger.ID]) {
	  cEgo.LockView(heroCombatView);
	}
	else {
	  cEgo.Loop = 5;
	}

}

/**
* Run from close combat
*/
function runCCombat()
{
	StopMusic();

	short i = 0;
	while (i < nEnemies)
	{
		if (!enemies[i].dead)
		{
			enemies[i].echar.ManualScaling = false;
			enemies[i].echar.UnlockView();
			enemies[i].echar.ChangeView(enemies[i].anmWalk);	
			enemies[i].echar.ChangeRoom(cEgo.PreviousRoom);
		}
		i++;
	}

	//Display(String.Format("enemyFollowType: %d", enemies[0].type));
  
	gMonsterbox.Visible = false;
	gStats.Visible = false;
	gCombatbox.Visible = false;
	gIconbar.Visible = true;
	gTopbar.Visible = true;
	  
    
	cEgo.UnlockView();
	cEgo.ChangeRoom(cEgo.PreviousRoom);
	
	SetRunningMode(1);
	SetTimer(Timer_FollowCharRooms, 1);
	SetTimer(Timer_FollowChar, 40);

	Mouse.Mode = eModeWalkto;
	
	//Display("%d", combatmonster.Room);
	//cEgo.Walk(0, cEgo.y, eNoBlock,eWalkableAreas); 
  
}

/**** Close combat update *******************************************************************************************/


/**
* Update hero animation during combat
*/
function updCCombatHero()
{
	if (cEgo.Animating) 
	{			

		// if thrust/slash/slice, monster attacks
		if (cEgo.Frame > 4 && !heroHitEnemy) 
		{
			if (cEgo.Loop == CbAnim_Attack1 || cEgo.Loop == CbAnim_Attack2 || cEgo.Loop == CbAnim_Attack3)
			{
				enemies[getFirstAliveEnemyId()].ReactAttack();
				heroHitEnemy = true;
			}
		}
	}

	if (!cEgo.Animating) {
		// free movement
		heroHitEnemy = false;
	}

}

/**
* Combat main update function
* Update hero and enemies and end combat when needed
*/
function updateCloseCombat() {
  
	if (cEgo.View == HEROVIEW) 
	{
		Display("No weapon! YOU'RE DEAD MEAT!");
		heroinfo.hp = 0;
	}
  
	// update enemy and hero
	int aliveEnemyId = getFirstAliveEnemyId();
	short i= aliveEnemyId;
	while (i < nEnemies)
	{
		enemies[i].updCCombat();
		i++;
	}
	updCCombatHero();

	// update GUI
	updCCombatGUI();	

	// check combat end
	if (heroinfo.hp <= 0) 
		onCCombatLose();
	
	if (aliveEnemyId == nEnemies)
		onCCombatWin();
	

}

/**** Debug *********************************************************************************************************************/

function killAllMonsters()
{
	if (!heroInCombat) return;
	
	short i=0;
	while (i < nEnemies)
	{
		if (IsCharacterWithinRoomBounds(enemies[i].echar))
		{
			enemies[i].hp = 0;
			enemies[i].Die();
		}
		i++;
	}
}


/**** Public functions  *********************************************************************************************/

function initCombatModule()
{
	initEnemyTypes();
}

function updateCombat()
{
  // monster should exist already, monster is spawned when room is entered (onEnterRoom_updCombat)
	if (!heroInCombat)
		return;

	if (cEgo.Room != combatRoomId)
		updateFarCombat();
	else
		updateCloseCombat();
		
  
}


function StopMonsterChasingAll() {
  
	// old function - Deprecated
  
	// stop any monster from chasing you and deletes them
	/*
	if (combatMonster.echar != null) 
		combatMonster.echar.ChangeRoom(-1);
	heroInCombat = false;
	*/

} �	  // Script header for module 'Combat'

import function DecreaseStamina(short val);
import function DecreaseHealth(short val);
import function GenericMonsterUse(Character *m);
import function killAllMonsters();


import function HeroAttack(short attacktype);
import function HeroBlock(short attacktype);
//import function enemyDie(Character *m);

import function initCombatModule();
import function InitCombat();
import function onEnterRoom_updCombat(short room);
import function updateCombat();

import function runCCombat();
import bool isHeroInCombat();
import bool isHeroDefeated();
import function StopMonsterChasingAll();

import function SpawnEnemyCoords(int enemyType,  short x, short y);

//import Character *combatmonster;
//import short monsterIsDead;
//import short enemyHP;

// a combat enemy
struct Enemy { 
	short id;	
	short type;
	String name;	
	Character* echar;

	// boolean states
	bool dead;
	bool searched;

	// views
	short anmWalk;
	short anmCombat;
	
	// speed
	short walkSpeed;
	short anmSpeed;
	
	// Hit Frames
	
	short hitFrame1; // hit frame for attack1 - COMPULSORY
	short hitFrame2;
	short hitFrame3;

	// sounds
	short gruntwav;
	short diewav;
	short hitmewav;

	// todo - check if these are needed
	//short combatfunc = ClayGolemCombat,
	//short lookfunc = "StalkerLook",
	//short usefunc = "GenericMonsterUse",
	//short itemdrop;

	// stats
	short hp;
	short mhp;
	short mp;
	short mmp;
	short str;
	short agi;
	short dodge;
	short luck;
	short weaponuse;

	// monster-only stats
	short mindmg;
	short maxdmg;
	short dmgtype;
	short armor;
	short magicarmor;
	short firearmor;
	short coldarmor;
	
	// money
	short gold;
	short silver;
	
	// currently disabled
	/*
	short itemdrop;
	short magicarmor;
	short firearmor;
	short coldarmor;
	*/
		
	// functions
	import bool isAttacking();
	import bool isBlocking(); 
	import bool isFlinching();
	import short calcHitProb();
	import short calcDamage();
	import short calcDodge();
	import short InflictDamageToHero();
	import short InflictDamageFromHero();
	import function Attack();
	import function Defend();
	import function BeIdle();
	import function Die();
	import function Flinch();
	import function ReactAttack();
	import function updateAI();
	import function updCCombat();
	import function updFCombat();
	import function updFollowHero();
	import function updFollowHeroNewRoom();
	import function genericUse();

};

 )z        ej��
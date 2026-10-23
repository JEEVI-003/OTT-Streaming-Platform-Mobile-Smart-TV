package com.VsmartEngine.MediaJungle.userregister;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.VsmartEngine.MediaJungle.model.User;




@Repository
public interface UserRegisterRepository extends JpaRepository<UserRegister, Long>{

	@Query("SELECT u FROM UserRegister u WHERE u.email = ?1")
    Optional<UserRegister> findByEmail(String email);
	
//	 @Query("SELECT u FROM UserRegister u WHERE u.date >= :startDate")
//	 List<UserRegister> findUsersRegisteredWithinLast15Days(LocalDate startDate);

	 @Query("SELECT new com.VsmartEngine.MediaJungle.userregister.UserRegisterDTO(u.username, u.date) " +
	           "FROM UserRegister u WHERE u.date >= :startDate")
	List<UserRegisterDTO> findUsersRegisteredWithinLast15Days(LocalDate startDate);
	 Optional<UserRegister> findById(Long userId);
//	 Optional<UserRegister> findByUserId(Long userId);
}

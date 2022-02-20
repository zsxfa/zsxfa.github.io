---
title: spring注解原理-IOC4 自动装配
date: 2022-01-26 20:16:50
tags: IOC
categories: Spring原理
---

自动装配原理...<!--more-->

[TOC]

# @Autowired、@Qualifier、@Primary的自动装配

## @Autowired注解

@Autowired注解可以对[类成员](https://so.csdn.net/so/search?q=类成员&spm=1001.2101.3001.7020)变量、方法和构造函数进行标注，完成自动装配的工作。@Autowired注解可以放在类、接口以及方法上。

在使用@Autowired注解之前，我们对一个bean配置属性时，是用如下XML配置文件的形式进行配置的。

```java
<property name="属性名" value=" 属性值"/>
```

下面我们来看一下@Autowired注解的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643247438.png)

这儿对@Autowired注解说明一下：

1. @Autowired注解默认是优先按照类型去容器中找对应的组件，相当于是调用了如下这个方法：

   ```java
   applicationContext.getBean(类名.class);
   ```

   若找到则就赋值。

2. 如果找到多个相同类型的组件，那么是将属性名称作为组件的id，到IOC容器中进行查找，这时就相当于是调用了如下这个方法：

   ```java
   applicationContext.getBean("组件的id");
   ```

## @Qualifier注解

@Autowired是根据类型进行自动装配的，如果需要按名称进行装配，那么就需要配合@Qualifier注解来使用了。

下面我们来看一下@Qualifier注解的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643247705.png)

## @Primary注解

在Spring中使用注解时，常常会使用到@Autowired这个注解，它默认是根据类型Type来自动注入的。但有些特殊情况，对同一个接口而言，可能会有几种不同的实现类，而在默认只会采取其中一种实现的情况下，就可以使用@Primary注解来标注优先使用哪一个实现类。

下面我们来看一下@Primary注解的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643247848.png)

# 自动装配

在进行项目实战之前，我们先来说说什么是Spring组件的自动装配。Spring组件的自动装配就是**Spring利用依赖注入，也就是我们通常所说的DI，完成对IOC容器中各个组件的依赖关系赋值。**

## 测试@Autowired注解

这里，我们以之前项目中创建的BookDao、BookService和BookController为例进行说明。

- BookDao

  ```java
  // 名字默认是类名首字母小写
  @Repository
  public class BookDao {
      
  }
  ```

- BookService

  ```java
  @Service
  public class BookService {
  
      @Autowired
      private BookDao bookDao;
      
      public void print() {
          System.out.println(bookDao);
      }
  }
  ```

- BookController

  ```java
  @Controller
  public class BookController {
      
      @Autowired
      private BookService bookService;
  }
  ```

可以看到，我们在BookService中使用@Autowired注解注入了BookDao，在BookController中使用@Autowired注解注入了BookService。为了方便测试，我们可以在BookService类中生成一个toString()方法，如下所示。

```java
@Service
public class BookService {

	@Autowired
	private BookDao bookDao;
	
	public void print() {
		System.out.println(bookDao);
	}

	@Override
	public String toString() {
		return "BookService [bookDao=" + bookDao + "]";
	}
}
```

为了更好的看到演示效果，我们在项目的com.zsxfa.config包下创建一个配置类，例如MainConfigOfAutowired，如下所示。

```java
@ComponentScan({"com.zsxfa.service", "com.zsxfa.dao", "com.zsxfa.controller"})
@Configuration
public class MainConfigOfAutowired {
}
```

接下来，我们便来测试一下上面的程序。在项目的src/test/java目录下的com.zsxfa.test包中创建一个单元测试类，例如IOCTest_Autowired，如下所示。

```java
public class IOCTest_Autowired {

    @Test
    public void test01() {
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfAutowired.class);

        BookService bookService = applicationContext.getBean(BookService.class);
        System.out.println(bookService);

        applicationContext.close();
    }
}
```

测试方法比较简单，这里我就不做过多说明了。然后，运行一下IOCTest_Autowired类中的test01()方法，得出的输出结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643248268.png)

可以看到，输出了BookDao信息。

**那么问题来了，我们在BookService类中使用@Autowired注解注入的BookDao（最后输出了该BookDao的信息），和我们直接在Spring IOC容器中获取的BookDao是不是同一个对象呢？**

为了说明这一点，我们可以在IOCTest_Autowired类的test01()方法中添加获取BookDao对象的方法，并输出获取到的BookDao对象，如下所示。

```java
public class IOCTest_Autowired {

    @Test
    public void test01() {
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfAutowired.class);

        BookService bookService = applicationContext.getBean(BookService.class);
        System.out.println(bookService);

        BookDao bookDao = applicationContext.getBean(BookDao.class);
        System.out.println(bookDao);
        
        applicationContext.close();
    }
}
```

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643248566.png)

可以看到，我们在BookService类中使用@Autowired注解注入的BookDao对象和直接从IOC容器中获取的BookDao对象是同一个对象。

你可能会问了，**如果在Spring容器中存在对多个BookDao对象，那么这时又该如何处理呢？**

首先，为了更加直观的看到我们使用@Autowired注解装配的是哪个BookDao对象，我们得对BookDao类进行改造，为其加上一个lable字段，并为其赋一个默认值，如下所示。

```java
// 名字默认是类名首字母小写
@Repository
public class BookDao {
	
	private String lable = "1";

	public String getLable() {
		return lable;
	}

	public void setLable(String lable) {
		this.lable = lable;
	}

	@Override
	public String toString() {
		return "BookDao [lable=" + lable + "]";
	}
}
```

然后，我们就在MainConfigOfAutowired配置类中注入一个BookDao对象，并且显示指定该对象在IOC容器中的bean的名称为bookDao2，并还为该对象的lable字段赋值为2，如下所示。

```java
@ComponentScan({"com.zsxfa.service", "com.zsxfa.dao", "com.zsxfa.controller"})
@Configuration
public class MainConfigOfAutowired {

    @Bean("bookDao2")
    public BookDao bookDao() {
        BookDao bookDao = new BookDao();
        bookDao.setLable("2");
        return bookDao;
    }
}
```

目前，在我们的IOC容器中就会注入两个BookDao对象。那此时，**@Autowired注解到底装配的是哪个BookDao对象呢？**

接着，我们来运行一下IOCTest_Autowired类中的test01()方法，发现输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643249310.png)

可以看到，结果信息输出了`lable=1`，这说明，**@Autowired注解默认是优先按照类型去容器中找对应的组件，找到就赋值；如果找到多个相同类型的组件，那么再将属性的名称作为组件的id，到IOC容器中进行查找。**

**那我们如何让@Autowired注解装配bookDao2呢？** 其实很简单，我们只须将BookService类中的bookDao属性的名称全部修改为bookDao2即可，如下所示。

```java
@Service
public class BookService {

	@Autowired
	private BookDao bookDao2;
	
	public void print() {
		System.out.println(bookDao2);
	}

	@Override
	public String toString() {
		return "BookService [bookDao2=" + bookDao2 + "]";
	}
}
```

此时，我们再运行IOCTest_Autowired类中的test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643249291.png)

## 测试@Qualifier注解

从测试@Autowired注解的结果来看，**@Autowired注解默认是优先按照类型去容器中找对应的组件，找到就赋值；如果找到多个相同类型的组件，那么再将属性的名称作为组件的id，到IOC容器中进行查找。**

如果IOC容器中存在多个相同类型的组件时，那么我们可不可以显示指定@Autowired注解装配哪个组件呢？有些小伙伴肯定会说：废话！你都这么问了，那肯定可以啊！没错，确实是可以的！此时，@Qualifier注解就派上用场了！

在之前的测试案例中，Eclipse控制台中输出了`BookDao [lable=2]`，这说明@Autowired注解装配了bookDao2，那我们如何显示的让@Autowired注解装配bookDao呢？

比较简单，我们只需要在BookService类里面的bookDao2字段上添加@Qualifier注解，显示指定@Autowired注解装配bookDao即可，如下所示。

```java
@Service
public class BookService {

	@Qualifier("bookDao")
	@Autowired
	private BookDao bookDao2;
	
	public void print() {
		System.out.println(bookDao2);
	}

	@Override
	public String toString() {
		return "BookService [bookDao2=" + bookDao2 + "]";
	}
}
```

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643249446.png)

可以看到，此时尽管字段的名称为bookDao2，但是我们使用了@Qualifier注解显示指定了@Autowired注解装配bookDao对象，所以，最终的结果中输出了bookDao对象的信息。

## 测试容器中无组件的情况

如果IOC容器中无相应的组件，那么会发生什么情况呢？这时我们可以做这样一件事情，先注释掉BookDao类上的@Repository注解

```java
// 名字默认是类名首字母小写
//@Repository
public class BookDao {
	
	private String lable = "1";

	public String getLable() {
		return lable;
	}

	public void setLable(String lable) {
		this.lable = lable;
	}

	@Override
	public String toString() {
		return "BookDao [lable=" + lable + "]";
	}
}
```

然后再注释掉MainConfigOfAutowired配置类中的bookDao()方法上的@Bean注解，如下所示。

```java
@Configuration
@ComponentScan({"com.meimeixia.service", "com.meimeixia.dao", "com.meimeixia.controller"})
public class MainConfigOfAutowired {

//	@Bean("bookDao2")
	public BookDao bookDao() {
		BookDao bookDao = new BookDao();
		bookDao.setLable("2");
		return bookDao;
	}
}
```

此时IOC容器中不再有任何BookDao对象了。

接着，我们再次运行IOCTest_Autowired类中的test01()方法，发现Eclipse控制台报了一个错误，如下。

```java
org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'bookService': Unsatisfied dependency expressed through field 'bookDao2'; nested exception is org.springframework.beans.factory.NoSuchBeanDefinitionException: No qualifying bean of type 'com.zsxfa.dao.BookDao' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {@org.springframework.beans.factory.annotation.Qualifier(value=bookDao), @org.springframework.beans.factory.annotation.Autowired(required=true)}
```

此时，Spring抛出了异常，未找到相应的bean对象，那我们能不能让Spring不报错呢？那肯定可以啊！抛出的异常信息中都给出了相应的提示。

```java
{@org.springframework.beans.factory.annotation.Qualifier(value=bookDao), @org.springframework.beans.factory.annotation.Autowired(required=true)}
```

解决方案就是在BookService类的@Autowired注解里面添加一个属性`required=false`，如下所示。

```java
@Service
public class BookService {

	@Qualifier("bookDao")
	@Autowired(required=false)
	private BookDao bookDao2;
	
	public void print() {
		System.out.println(bookDao2);
	}

	@Override
	public String toString() {
		return "BookService [bookDao2=" + bookDao2 + "]";
	}
}
```

加上`required=false`这个玩意的意思就是说找到就装配，找不到就拉到，就别装配了。

此时，还需要将IOCTest_Autowired类的test01()方法中直接从IOC容器中获取BookDao对象的代码注释掉，如下所示。

```java
public class IOCTest_Autowired {
	
	@Test
	public void test01() {
		AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfAutowired.class);
		
		BookService bookService = applicationContext.getBean(BookService.class);
		System.out.println(bookService);
		
//		BookDao bookDao = applicationContext.getBean(BookDao.class);
//		System.out.println(bookDao);
		
		applicationContext.close();
	}
}
```

紧接着，我们再次运行以上test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643249762.png)

可以看到，当为@Autowired注解添加属性`required=false`后，即使IOC容器中没有对应的对象，Spring也不会抛出异常了。不过，此时装配的对象就为null了。

测试完成后，我们还得恢复原样，即再次为BookDao类添加@Repository注解，并且在MainConfigOfAutowired配置类中的bookDao()方法上添加@Bean注解，好方便进一步的测试。

## 测试@Primary注解

在Spring中，对同一个接口而言，可能会有几种不同的实现类，而默认只会采取其中一种实现的情况下，就可以使用@Primary注解来标注优先使用哪一个实现类。

如果IOC容器中相同类型的组件有多个，那么我们不可避免地就要来回用@Qualifier注解来指定要装配哪个组件，这还是比较麻烦的，Spring正是帮我们考虑到了这样一种情况，就提供了这样一个比较强大的注解，即@Primary。我们可以利用这个注解让Spring进行自动装配的时候，默认使用首选的bean。

说了这么多，下面我们就用一个小例子来测试一下@Primary注解。

首先，我们在MainConfigOfAutowired配置类的bookDao()方法上添加上@Primary注解，如下所示。

```java
@Configuration
@ComponentScan({"com.zsxfa.service", "com.zsxfa.dao", "com.zsxfa.controller"})
public class MainConfigOfAutowired {
	
	@Primary
	@Bean("bookDao2")
	public BookDao bookDao() {
		BookDao bookDao = new BookDao();
		bookDao.setLable("2");
		return bookDao;
	}
}
```

注意：此时，我们需要注释掉BookService类中bookDao字段上的@Qualifier注解，这是因为@Qualifier注解为显示指定装配哪个组件，如果使用了@Qualifier注解，无论是否使用了@Primary注解，都会装配@Qualifier注解标注的对象。

```java
@Service
public class BookService {

//	@Qualifier("bookDao") // 要让首选装配起效果，@Qualifier自然就不能用了
	@Autowired(required=false)
	private BookDao bookDao;
	
	public void print() {
		System.out.println(bookDao);
	}

	@Override
	public String toString() {
		return "BookService [bookDao=" + bookDao + "]";
	}
}
```

设置完成后，我们再次运行IOCTest_Autowired类中的test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643250008.png)

可以看到，此时lable的值为2，这说明装配了MainConfigOfAutowired配置类中注入的bookDao2。

那我们非要装配bookDao，可不可以呢？当然可以了，我们只须使用@Qualifier("bookDao")来显示指定装配bookDao即可。也就是说如果是在没有明确指定的情况下，那么就装配优先级最高的首选的那个bean，如果是在明确指定了的情况下，那么自然就是装配指定的那个bean了。

# @Resource注解和@Inject注解

## @Resource注解

@Resource注解是Java规范里面的，也可以说它是JSR250规范里面定义的一个注解。该注解默认按照名称进行装配，名称可以通过name属性进行指定，如果没有指定name属性，当注解写在字段上时，那么默认取字段名将其作为组件的名称在IOC容器中进行查找，如果注解写在setter方法上，那么默认取属性名进行装配。当找不到与名称匹配的bean时才按照类型进行装配。但是需要注意的一点是，如果name属性一旦指定，那么就只会按照名称进行装配。

我们先看一下@Resource注解的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643250318.png)

## @Inject注解

@Inject注解也是Java规范里面的，也可以说它是JSR330规范里面定义的一个注解。该注解默认是根据参数名去寻找bean注入，支持Spring的@Primary注解优先注入，@Inject注解还可以增加@Named注解指定要注入的bean。

我们先看一下@Inject注解的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643250595.png)

**温馨提示，要想使用@Inject注解，需要在项目的pom.xml文件中添加如下依赖，即导入javax.inject这个包。**

```xml
<dependency>
    <groupId>javax.inject</groupId>
    <artifactId>javax.inject</artifactId>
    <version>1</version>
</dependency>
```

## 测试@Resource注解

首先，我们将项目中的BookService类标注在bookDao字段上的@Autowired注解和@Qualifier注解注释掉，然后添加上@Resource注解，如下所示。

```java
@Service
public class BookService {

//	@Qualifier("bookDao") // 要让首选装配起效果，@Qualifier自然就不能用了
//	@Autowired(required=false)
	@Resource
	private BookDao bookDao;
	
	public void print() {
		System.out.println(bookDao);
	}

	@Override
	public String toString() {
		return "BookService [bookDao=" + bookDao + "]";
	}
}
```

然后，我们运行一下IOCTest_Autowired类中的test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643250776.png)

可以看到，使用@Resource注解也能够自动装配组件，只不过此时自动装配的是lable为1的bookDao，而不是我们在MainConfigOfAutowired配置类中配置的优先装配的lable为2的bookDao。MainConfigOfAutowired配置类中配置的lable为2的bookDao如下所示。

```java
@Configuration
@ComponentScan({"com.meimeixia.service", "com.meimeixia.dao", "com.meimeixia.controller"})
public class MainConfigOfAutowired {
	
	@Primary
	@Bean("bookDao2")
	public BookDao bookDao() {
		BookDao bookDao = new BookDao();
		bookDao.setLable("2");
		return bookDao;
	}
}
```

这也进一步说明，**@Resource注解和@Autowired注解的功能是一样的，都能实现自动装配，只不过@Resource注解默认是按照组件名称（即属性的名称）进行装配的。虽然@Resource注解具备自动装配这一功能，但是它是不支持@Primary注解优先注入的功能的，而且也不能像@Autowired注解一样能添加`required=false`属性。**

我们在使用@Resource注解时，可以通过@Resource注解的name属性显示指定要装配的组件的名称。例如，我们要想装配lable为2的bookDao，只需要为@Resource注解添加 `name="bookDao2"`属性即可，如下所示。

```java
@Service
public class BookService {

//	@Qualifier("bookDao") // 要让首选装配起效果，@Qualifier自然就不能用了
//	@Autowired(required=false)
	@Resource(name="bookDao2")
	private BookDao bookDao;
	
	public void print() {
		System.out.println(bookDao);
	}

	@Override
	public String toString() {
		return "BookService [bookDao=" + bookDao + "]";
	}
}
```

接着，我们再次运行IOCTest_Autowired类中的test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643250995.png)

可以看到，此时输出了lable为2的bookDao，说明@Resource注解可以通过name属性显示指定要装配的bean。

## 测试@Inject注解

在BookService类中，将@Resource注解注释掉，添加@Inject注解，如下所示。

```java
@Service
public class BookService {

    //	@Qualifier("bookDao") // 要让首选装配起效果，@Qualifier自然就不能用了
//	@Autowired(required=false)
//    @Resource(name="bookDao2")
    @Inject
    private BookDao bookDao;

    public void print() {
        System.out.println(bookDao);
    }

    @Override
    public String toString() {
        return "BookService [bookDao=" + bookDao + "]";
    }
}
```

修改完毕后，我们运行IOCTest_Autowired类中的test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643251094.png)

可以看到，使用@Inject注解默认输出的是lable为2的bookDao。这是因为@Inject注解和@Autowired注解一样，默认优先装配使用了@Primary注解标注的组件。

其实，这也进一步说明了，**@Inject注解和@Autowired注解的功能是一样的，都能实现自动装配，而且它俩都支持@Primary注解优先注入的功能。只不过，@Inject注解不能像@Autowired注解一样能添加`required=false`属性，因为它里面没啥属性。**

## @Resource和@Inject这俩注解与@Autowired注解的区别

### 不同点

- @Autowired是Spring中的专有注解，而@Resource是Java中JSR250规范里面定义的一个注解，@Inject是Java中JSR330规范里面定义的一个注解
- @Autowired支持参数`required=false`，而@Resource和@Inject都不支持
- @Autowired和@Inject支持@Primary注解优先注入，而@Resource不支持
- @Autowired通过@Qualifier指定注入特定bean，@Resource可以通过参数name指定注入bean，而@Inject需要通过@Named注解指定注入bean

### 相同点

三种注解都可以实现bean的自动装配。

# 实现方法、构造器位置的自动装配

## 再谈@Autowired注解

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643247438.png)

我们通过@Autowired注解的源码可以看出，在@Autowired注解上标注有如下的注解信息。

```java
@Target({ElementType.CONSTRUCTOR, ElementType.METHOD, ElementType.PARAMETER, ElementType.FIELD, ElementType.ANNOTATION_TYPE})
```

可以看出@Autowired注解不仅可以标注在字段上，而且还可以标注在构造方法、实例方法以及参数上。

## 案例准备

首先，我们在项目中新建一个Boss类，在Boss类中有一个Car类的引用，并且我们使用@Component注解将Dog类加载到IOC容器中，如下所示。

```java
// 默认加在IOC容器中的组件，容器启动会调用无参构造器创建对象，然后再进行初始化、赋值等操作
@Component
public class Boss {
	
	private Car car;

	public Car getCar() {
		return car;
	}

	public void setCar(Car car) {
		this.car = car;
	}

	@Override
	public String toString() {
		return "Boss [car=" + car + "]";
	}
}
```

注意，Car类上也要标注@Component注解，即它也要被加载到IOC容器中。

新建好以上Boss类之后，我们还需要在MainConfigOfAutowired配置类的@ComponentScan注解中进行配置，使其能够扫描com.meimeixia.bean包下的类，如下所示。

```java
@ComponentScan({"com.zsxfa.service", "com.zsxfa.dao", "com.zsxfa.controller","com.zsxfa.bean"})
@Configuration
public class MainConfigOfAutowired {

    @Primary
    @Bean("bookDao2")
    public BookDao bookDao() {
        BookDao bookDao = new BookDao();
        bookDao.setLable("2");
        return bookDao;
    }
}
```

此时，我们就可以直接在Boss类中的car字段上添加@Autowired注解，使其自动装配。

## 标注在实例方法上

我们可以将@Autowired注解标注在setter方法上，如下所示。

```java
@Autowired 
public void setCar(Car car) {
    this.car = car;
}
```

**当@Autowired注解标注在方法上时，Spring容器在创建当前对象的时候，就会调用相应的方法为对象赋值。如果标注的方法存在参数时，那么方法使用的参数和自定义类型的值，需要从IOC容器中获取。**

然后，我们将IOCTest_Autowired类的test01()方法中有关获取和打印BookService信息的代码注释掉，新增获取和打印Boss信息的代码，如下所示。

```java
public class IOCTest_Autowired {

    @Test
    public void test01() {
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfAutowired.class);

//		BookService bookService = applicationContext.getBean(BookService.class);
//		System.out.println(bookService);

//		BookDao bookDao = applicationContext.getBean(BookDao.class);
//		System.out.println(bookDao);

        Boss boss = applicationContext.getBean(Boss.class);
        System.out.println(boss);

        applicationContext.close();
    }
}
```

运行以上test01()方法进行测试，可以看到，结果信息中输出了如下一行信息。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643252468.png)

说明已经获取到了car的信息，也就是说可以将@Autowired注解标注在方法上。

为了验证最终的输出结果是否是从IOC容器中获取的，我们可以在IOCTest_Autowired类的test01()方法中直接获取Car对象的信息，如下所示。

```java
public class IOCTest_Autowired {

    @Test
    public void test01() {
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfAutowired.class);

//		BookService bookService = applicationContext.getBean(BookService.class);
//		System.out.println(bookService);

//		BookDao bookDao = applicationContext.getBean(BookDao.class);
//		System.out.println(bookDao);

        Boss boss = applicationContext.getBean(Boss.class);
        System.out.println(boss);

        Car car = applicationContext.getBean(Car.class);
        System.out.println(car);
        
        applicationContext.close();
    }
}
```

我们再次运行以上test01()方法进行测试，可以在输出的结果信息中看到如下两行内容。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643252579.png)

这已然说明在Boss类中通过@Autowired注解获取到的Car对象和直接从IOC容器中获取到Car对象是同一个对象。

## 标注在构造方法上

在上面的案例中，我们在Boss类上使用了@Component注解，如下所示。

```java
// 默认加在IOC容器中的组件，容器启动会调用无参构造器创建对象，然后再进行初始化、赋值等操作
@Component
public class Boss {
	
	private Car car;

	public Car getCar() {
		return car;
	}

    @Autowired
	public void setCar(Car car) {
		this.car = car;
	}

	@Override
	public String toString() {
		return "Boss [car=" + car + "]";
	}
}
```

此时，Spring会默认将该类加载进IOC容器中，IOC容器启动的时候默认会调用bean的无参构造器创建对象，然后再进行初始化、赋值等操作。

接下来，我们为Boss类添加一个有参构造方法，然后去除setCar()方法上的@Autowired注解，将@Autowired注解标注在有参构造方法上，并在构造方法中打印一条信息，如下所示。

```java
// 默认加在IOC容器中的组件，容器启动会调用无参构造器创建对象，然后再进行初始化、赋值等操作
@Component
public class Boss {
	
	private Car car;
	
	@Autowired
	public Boss(Car car) {
		this.car = car;
		System.out.println("Boss...有参构造器");
	}

	public Car getCar() {
		return car;
	}

	public void setCar(Car car) {
		this.car = car;
	}

	@Override
	public String toString() {
		return "Boss [car=" + car + "]";
	}
}
```

接着，我们运行IOCTest_Autowired类中的test01()方法进行测试，可以看到输出结果信息中存在如下一行信息。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643252752.png)

说明IOC容器在启动的时候调用了Boss类的有参构造方法。并且还可以从输出的如下两行信息中看出，通过Boss类的toString()方法打印出的Car对象和直接从IOC容器中获取的Car对象是同一个对象。

**使用@Autowired注解标注在构造方法上时，构造方法中的参数对象也是从IOC容器中获取的。**

**使用@Autowired注解标注在构造方法上时，如果组件中只有一个有参构造方法，那么这个有参构造方法上的@Autowired注解可以省略，并且参数位置的组件还是可以自动从IOC容器中获取。**

## 标注在参数上

我们也可以将@Autowired注解标注在参数上，例如，在Boss类中我们将构造方法上的@Autowired注解标注在构造方法的参数上，如下所示。

```java
public Boss(@Autowired Car car) {
    this.car = car;
    System.out.println("Boss...有参构造器");
}
```

当然了，也可以将@Autowired注解标注在setter方法的参数上，如下所示。

```java
public void setCar(@Autowired Car car) {
    this.car = car;
}
```

最终的效果与标注在字段、实例方法和构造方法上的效果都是一样的。

结论：**无论@Autowired注解是标注在字段上、实例方法上、构造方法上还是参数上，参数位置的组件都是从IOC容器中获取。**



如果Spring的bean中只有一个有参构造方法，并且这个有参构造方法只有一个参数，这个参数还是IOC容器中的对象，当@Autowired注解标注在这个构造方法的参数上时，那么我们可以将其省略掉，如下所示。

```java
public Boss(/*@Autowired*/ Car car) {
    this.car = car;
    System.out.println("Boss...有参构造器");
}
```

## 标注在方法位置

@Autowired注解可以标注在某个方法的位置上。这里，为了更好的演示效果，我们新建一个Color类，在Color类中有一个Car类型的成员变量，如下所示。

```java
public class Color {
	
	public Car car;

	public Car getCar() {
		return car;
	}

	public void setCar(Car car) {
		this.car = car;
	}

	@Override
	public String toString() {
		return "Color [car=" + car + "]";
	}
}
```

然后，我们在MainConfigOfAutowired配置类中实例化Color类，如下所示。

```java
@Bean
public Color color() {
    Color color = new Color();
    return color;
}
```

接着，我们在IOCTest_Autowired类中再创建一个test02()测试方法，如下所示。

```java
@Test
public void test02() {
    AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfAutowired.class);
    
    Color color = applicationContext.getBean(Color.class);
    System.out.println(color);
    
    applicationContext.close();
}
```

紧接着，运行以上test02()方法，发现在输出的结果信息中存在如下一行信息。

> Color [car=null]

说明此时的Color对象中的Car对象为空。此时，我们可以将Car对象作为一个参数传递到MainConfigOfAutowired配置类的color()方法中，并且将该Car对象设置到Color对象中，如下所示。

```
@Bean
public Color color(Car car) {
    Color color = new Color();
    color.setCar(car);
    return color;
}
```

当然了，我们也可以使用@Autowired注解来标注color()方法中的car参数，就像下面这样。

```java
@Bean
public Color color(@Autowired Car car) {
    Color color = new Color();
    color.setCar(car);
    return color;
}
```

接下来，我们再次运行test02()方法，可以看到在输出的结果信息中存在如下一行信息。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643253171.png)

说明Car对象被成功创建并设置到Color对象中了。

至此，我们可以得出结论：**如果方法只有一个IOC容器中的对象作为参数，当@Autowired注解标注在这个方法的参数上时，我们可以将@Autowired注解省略掉。也就说@Bean注解标注的方法在创建对象的时候，方法参数的值是从IOC容器中获取的，此外，标注在这个方法的参数上的@Autowired注解可以省略。**

**其实，我们用到最多的还是把@Autowired注解标注在方法位置，即使用@Bean注解+方法参数这种形式，此时，该方法参数的值从IOC容器中获取，并且还可以默认不写@Autowired注解，因为效果都是一样的，都能实现自动装配！**

# Aware注入spring底层组件&原理

自定义的组件要想使用Spring容器底层的一些组件，比如ApplicationContext（IOC容器）、底层的BeanFactory等等，那么只需要让自定义组件实现XxxAware接口即可。此时，Spring在创建对象的时候，会调用XxxAware接口中定义的方法注入相关的组件。

## XxxAware接口概览

其实，我们之前使用过XxxAware接口，例如，我们之前创建的Dog类，就实现了ApplicationContextAware接口，Dog类的源码如下所示。

```java
/**
 * ApplicationContextAwareProcessor这个类的作用是可以帮我们在组件里面注入IOC容器，
 * 怎么注入呢？我们想要IOC容器的话，比如我们这个Dog组件，只需要实现ApplicationContextAware接口就行
 */
@Component
public class Dog implements ApplicationContextAware {
	
	private ApplicationContext applicationContext;

	public Dog() {
		System.out.println("dog constructor...");
	}
	
	// 在对象创建完成并且属性赋值完成之后调用
	@PostConstruct
	public void init() { // 在这儿打个断点调试一下
		System.out.println("dog...@PostConstruct...");
	}
	
	// 在容器销毁（移除）对象之前调用
	@PreDestroy
	public void destory() {
		System.out.println("dog...@PreDestroy...");
	}

	@Override
	public void setApplicationContext(ApplicationContext applicationContext) throws BeansException { // 在这儿打个断点调试一下
		// TODO Auto-generated method stub
		this.applicationContext = applicationContext;
	}
}
```

从以上Dog类的源码中可以看出，实现ApplicationContextAware接口的话，需要实现setApplicationContext()方法。在IOC容器启动并创建Dog对象时，Spring会调用setApplicationContext()方法，并且会将ApplicationContext对象传入到setApplicationContext()方法中，我们只需要在Dog类中定义一个ApplicationContext类型的成员变量来接收setApplicationContext()方法中的参数，那么便可以在Dog类的其他方法中使用ApplicationContext对象了。

其实，在Spring中，类似于ApplicationContextAware接口的设计有很多，本质上，Spring中形如XxxAware这样的接口都继承了Aware接口，我们来看下Aware接口的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643253950.png)

可以看到，Aware接口是Spring 3.1版本中引入的接口，在Aware接口中，并未定义任何方法。

接下来，我们看看都有哪些接口继承了Aware接口，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643254495.png)

## XxxAware接口案例

接下来，我们就挑选几个常用的XxxAware接口来简单的说明一下。

ApplicationContextAware接口使用的比较多，我们先来说说这个接口，通过ApplicationContextAware接口我们可以获取到IOC容器。

首先，我们创建一个Red类，它得实现ApplicationContextAware接口，并在实现的setApplicationContext()方法中将ApplicationContext输出，如下所示。

```java
// *  * 以Red类为例来讲解ApplicationContextAware接口、BeanNameAware接口以及EmbeddedValueResolverAware接口
public class Red implements ApplicationContextAware {
	
	private ApplicationContext applicationContext;

	@Override
	public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
		System.out.println("传入的IOC：" + applicationContext);
		this.applicationContext = applicationContext;
	}
}
```

其实，我们也可以让Red类同时实现几个XxxAware接口，例如，使Red类再实现一个BeanNameAware接口，我们可以通过BeanNameAware接口获取到当前bean在Spring容器中的名称，如下所示。

```java
//以Red类为例来讲解ApplicationContextAware接口、BeanNameAware接口以及EmbeddedValueResolverAware接口
public class Red implements ApplicationContextAware, BeanNameAware {

    private ApplicationContext applicationContext;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        System.out.println("传入的IOC：" + applicationContext);
        this.applicationContext = applicationContext;
    }

    //参数name：IOC容器创建当前对象时，为这个对象起的名字
    @Override
    public void setBeanName(String name) {
        System.out.println("当前bean的名字：" + name);
    }
}
```

当然了，我们可以再让Red类实现一个EmbeddedValueResolverAware接口，我们通过EmbeddedValueResolverAware接口能够获取到String值解析器，如下所示。

```java
//以Red类为例来讲解ApplicationContextAware接口、BeanNameAware接口以及EmbeddedValueResolverAware接口
public class Red implements ApplicationContextAware, BeanNameAware, EmbeddedValueResolverAware {

    private ApplicationContext applicationContext;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        System.out.println("传入的IOC：" + applicationContext);
        this.applicationContext = applicationContext;
    }

    //参数name：IOC容器创建当前对象时，为这个对象起的名字
    @Override
    public void setBeanName(String name) {
        System.out.println("当前bean的名字：" + name);
    }

    //参数resolver：IOC容器启动时会自动地将这个String值的解析器传递过来给我们
    @Override
    public void setEmbeddedValueResolver(StringValueResolver resolver) {
        String resolveStringValue = resolver.resolveStringValue("你好，${os.name}，我的年龄是#{20*18}");
        System.out.println("解析的字符串：" + resolveStringValue);
    }
}
```

IOC容器启动时会自动地将String值的解析器（即StringValueResolver）传递过来给我们用，咱们可以用它来解析一些字符串，解析哪些字符串呢？比如包含`#{}`这样的字符串。我们可以看一下StringValueResolver类的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643254774.png)

从描述中可以看出，它是用来帮我们解析那些String类型的值的，如果这个String类型的值里面有一些占位符，那么也会帮我们把这些占位符给解析出来，最后返回一个解析后的值。

接着，我们需要在Red类上标注@Component注解将该类添加到IOC容器中，如下所示。

```java
@Component
public class Red implements ApplicationContextAware, BeanNameAware, EmbeddedValueResolverAware {
```

最后，运行IOCTest_Autowired类中的test02()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643255209.png)

在自定义的组件中获取到的IOC容器和测试方法中获取到的IOC容器是不是同一个东东呢？带着这样一个疑问，不妨试试运行一下以下test02()方法。

```java
@Test
public void test02() {
    AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfAutowired.class);
    
    Color color = applicationContext.getBean(Color.class);
    System.out.println(color);
    
    System.out.println(applicationContext); // 测试用到的IOC容器
    
    applicationContext.close();
}
```

可以看到输出了如下所示的结果信息。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643255352.png)

这已然说明了在咱们自定义的组件中获取到的IOC容器和测试方法中获取到的IOC容器是同一个

## XxxAware原理

XxxAware接口的底层原理是由XxxAwareProcessor实现类实现的，也就是说每一个XxxAware接口都有它自己对应的XxxAwareProcessor实现类。 例如，我们这里以ApplicationContextAware接口为例，ApplicationContextAware接口的底层原理就是由ApplicationContextAwareProcessor类实现的。从ApplicationContextAwareProcessor类的源码可以看出，其实现了BeanPostProcessor接口，本质上是一个后置处理器。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643255447.png)

接下来，我们就以分析ApplicationContextAware接口的原理为例，看看Spring是怎么将ApplicationContext对象注入到Red类中的。

首先，我们在Red类的setApplicationContext()方法上打一个断点，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643255496.png)

然后，我们以debug的方式来运行IOCTest_Autowired类中的test02()方法。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643255623.png)

这里，我们可以看到，实际上ApplicationContext对象已经注入到Red类的setApplicationContext()方法中了。

接着，我们在IDEA的方法调用栈中找到postProcessBeforeInitialization()方法并鼠标单击它，如下所示，此时，自动定位到了postProcessBeforeInitialization()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643255669.png)

其实，postProcessBeforeInitialization()方法所在的类就是ApplicationContextAwareProcessor。postProcessBeforeInitialization()方法的逻辑还算比较简单。

紧接着，我们来看下在postProcessBeforeInitialization()方法中调用的invokeAwareInterfaces()方法，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643255767.png)

# @Profile

在实际的企业开发环境中，往往都会将环境分为开发环境、测试环境和生产环境，并且每个环境基本上都是互相隔离的，也就是说，开发环境、测试环境和生产环境它们之间是互不相通的。在以前的开发过程中，如果开发人员完成相应的功能模块并通过单元测试后，那么他会通过手动修改配置文件的形式，将项目的配置修改成测试环境，发布到测试环境中进行测试。测试通过后，再将配置修改为生产环境，发布到生产环境中。这样手动修改配置的方式，不仅增加了开发和运维的工作量，而且总是手工修改各项配置文件会很容易出问题。那么，有没有什么方式可以解决这些问题呢？答案是：有！通过@Profile注解就可以完全做到这点。

## @Profile注解概述

在容器中如果存在同一类型的多个组件，那么可以使用@Profile注解标识要获取的是哪一个bean。也可以说@Profile注解是Spring为我们提供的可以根据当前环境，动态地激活和切换一系列组件的功能。这个功能在不同的环境使用不同的变量的情景下特别有用，例如，开发环境、测试环境、生产环境使用不同的数据源，在不改变代码的情况下，可以使用这个注解来动态地切换要连接的数据库。

接下来，我们来看下@Profile注解的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643267392.png)

从其源码中我们可以得出如下三点结论：

-  @Profile注解不仅可以标注在方法上，也可以标注在配置类上。
- 如果@Profile注解标注在配置类上，那么只有是在指定的环境的时候，整个配置类里面的所有配置才会生效。
- 如果一个bean上没有使用@Profile注解进行标注，那么这个bean在任何环境下都会被注册到IOC容器中，当然了，前提是在整个配置类生效的情况下。

第一点很容易看出，勿须再说，后面两点如果你要是初次认识@Profile注解的话，那么是肯定看不出来的，得通过下面的讲解才能知道。

## 实战案例

接下来，我们就一起来看一个案例，即使用@Profile注解实现开发、测试和生产环境的配置和切换。这里，我们以开发过程中要用到的数据源为例。我们希望在开发环境中，数据源是连向A数据库的；在测试环境中，数据源是连向B数据库的，而且在这一过程中，测试人员压根就不需要改动任何代码；最终项目上线之后，数据源连向C数据库，而且最重要的一点是在整个过程中，我们不希望改动大量的代码，而实现数据源的切换。

### 环境搭建

首先，我们需要在pom.xml文件中添加c3p0数据源和MySQL驱动的依赖，如下所示。

```java
<dependency>
    <groupId>c3p0</groupId>
    <artifactId>c3p0</artifactId>
    <version>0.9.1.2</version>
</dependency>
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>5.1.44</version>
</dependency>
```

添加完以上依赖之后，我们还得在项目中新建一个配置类，例如MainConfigOfProfile，并在该配置类中模拟开发、测试、生产环境的数据源，如下所示。

```java
@Configuration
public class MainConfigOfProfile {

    @Bean("testDataSource")
    public DataSource dataSourceTest() throws Exception {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser("root");
        dataSource.setPassword("123456");
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/test");
        dataSource.setDriverClass("com.mysql.jdbc.Driver");
        return dataSource;
    }

    @Bean("devDataSource")
    public DataSource dataSourceDev() throws Exception {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser("root");
        dataSource.setPassword("123456");
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/ssm_crud");
        dataSource.setDriverClass("com.mysql.jdbc.Driver");
        return dataSource;
    }

    @Bean("prodDataSource")
    public DataSource dataSourceProd() throws Exception {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser("root");
        dataSource.setPassword("123456");
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/scw_0515");
        dataSource.setDriverClass("com.mysql.jdbc.Driver");
        return dataSource;
    }
}
```

该配置类这样写，是一点儿问题都没有的，但你有没有想过这一点，在真实项目开发中，那些数据库连接的相关信息，例如用户名、密码以及MySQL数据库驱动类的全名，这些都是要抽取在一个配置文件中的。你想一想，是不是这么一回事啊！

因此，我们需要在项目的src/main/resources目录下新建一个配置文件，例如dbconfig.properties，在其中写上数据库连接的相关信息，如下所示。

```java
db.user=root
db.password=123456
db.driverClass=com.mysql.jdbc.Driver
```

那么如何在MainConfigOfProfile配置类中获取以上配置文件中的值呢？

该MainConfigOfProfile配置类实现了一个EmbeddedValueResolverAware接口，我们通过该接口能够获取到String值解析器。也就是说，IOC容器启动时会自动地将String值的解析器（即StringValueResolver）传递过来给我们用，咱们可以用它来解析一些字符串。

```java
@PropertySource("classpath:/dbconfig.properties") // 加载外部的配置文件
@Configuration
public class MainConfigOfProfile implements EmbeddedValueResolverAware {

    @Value("${db.user}")
    private String user;
    private StringValueResolver valueResolver;
    private String dirverClass;

    @Bean("testDataSource")
    public DataSource dataSourceTest(@Value("${db.password}") String pwd) throws Exception {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/test");
        dataSource.setDriverClass("com.mysql.jdbc.Driver");
        return dataSource;
    }

    @Bean("devDataSource")
    public DataSource dataSourceDev(@Value("${db.password}") String pwd) throws Exception {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/ssm_crud");
        dataSource.setDriverClass(dirverClass);
        return dataSource;
    }

    @Bean("prodDataSource")
    public DataSource dataSourceProd(@Value("${db.password}") String pwd) throws Exception {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/scw_0515");
        dataSource.setDriverClass(dirverClass);
        return dataSource;
    }

    @Override
    public void setEmbeddedValueResolver(StringValueResolver resolver) {
        this.valueResolver = resolver;
        dirverClass = valueResolver.resolveStringValue("${db.driverClass}");
    }
}
```

其实，这个配置类相对来说还算是比较简单的，其中使用`@Bean("devDataSource")`注解标注的是开发环境使用的数据源；使用`@Bean("testDataSource")`注解标注的是测试环境使用的数据源；使用`@Bean("prodDataSource")`注解标注的是生产环境使用的数据源。

接着，我们创建一个单元测试类，例如IOCTest_Profile，并在该类中新建一个test01()方法来进行测试，如下所示。

```java
public class IOCTest_Profile {

    @Test
    public void test01() {
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfProfile.class);

        String[] namesForType = applicationContext.getBeanNamesForType(DataSource.class);
        for (String name : namesForType) {
            System.out.println(name);
        }

        // 关闭容器
        applicationContext.close();
    }
}
```

最后，运行以上test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643268334.png)

可以看到三种不同的数据源成功注册到了IOC容器中，说明我们的环境搭建成功了。

### 根据环境注册bean

我们成功搭建环境之后，接下来，就是要实现根据不同的环境来向IOC容器中注册相应的bean了。也就是说，我们要实现在开发环境注册开发环境下使用的数据源；在测试环境注册测试环境下使用的数据源；在生产环境注册生产环境下使用的数据源。此时，@Profile注解就显示出其强大的特性了。

我们在MainConfigOfProfile配置类中为每个数据源添加@Profile注解标识，如下所示。

```java
@PropertySource("classpath:/dbconfig.properties") // 加载外部的配置文件
@Configuration
public class MainConfigOfProfile implements EmbeddedValueResolverAware {

    @Value("${db.user}")
    private String user;
    private StringValueResolver valueResolver;
    private String dirverClass;

    @Profile("test")
    @Bean("testDataSource")
    public DataSource dataSourceTest(@Value("${db.password}") String pwd) throws Exception {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/test");
        dataSource.setDriverClass("com.mysql.jdbc.Driver");
        return dataSource;
    }

    @Profile("dev") // 定义了一个环境标识，只有当dev环境被激活以后，我们这个bean才能被注册进来
    @Bean("devDataSource")
    public DataSource dataSourceDev(@Value("${db.password}") String pwd) throws Exception {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/ssm_crud");
        dataSource.setDriverClass(dirverClass);
        return dataSource;
    }

    @Profile("prod")
    @Bean("prodDataSource")
    public DataSource dataSourceProd(@Value("${db.password}") String pwd) throws Exception {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/scw_0515");
        dataSource.setDriverClass(dirverClass);
        return dataSource;
    }

    @Override
    public void setEmbeddedValueResolver(StringValueResolver resolver) {
        this.valueResolver = resolver;
        dirverClass = valueResolver.resolveStringValue("${db.driverClass}");
    }
}
```

可以看到，我们使用`@Profile("dev")`注解来标识在开发环境下注册devDataSource；使用`@Profile("test")`注解来标识在测试环境下注册testDataSource；使用`@Profile("prod")`注解来标识在生产环境下注册prodDataDource。

此时，我们运行IOCTest_Profile类中的test01()方法，**发现IDEA控制台并未输出任何结果信息。** 说明我们为不同的数据源添加@Profile注解后，默认是不会向IOC容器中注册bean的，需要我们根据环境显示指定向IOC容器中注册相应的bean。

**换句话说，通过@Profile注解加了环境标识的bean，只有这个环境被激活的时候，相应的bean才会被注册到IOC容器中。**

如果我们需要一个默认的环境，那么该怎么办呢？此时，我们可以通过`@Profile("default")`注解来标识一个默认的环境，例如，我们将devDataSource环境标识为默认环境，如下所示。

```java
@Profile("default")
// @Profile("dev") // 定义了一个环境标识，只有当dev环境被激活以后，我们这个bean才能被注册进来
@Bean("devDataSource")
public DataSource dataSourceDev(@Value("${db.password}") String pwd) throws Exception {
    ComboPooledDataSource dataSource = new ComboPooledDataSource();
    dataSource.setUser(user);
    dataSource.setPassword(pwd);
    dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/ssm_crud");
    dataSource.setDriverClass(dirverClass);
    return dataSource;
}
```

此时，我们运行IOCTest_Profile类中的test01()方法，输出的结果信息:

> devDataSource

可以看到，我们在devDataSource数据源上使用`@Profile("default")`注解将其设置为默认的数据源，运行测试方法时IDEA控制台会输出devDataSource。

接下来，我们将devDataSource数据源上的`@Profile("default")`注解还原成`@Profile("dev")`注解，重新标识它为一个开发环境下注册的数据源，好方便下面的测试。

那么，我们如何根据不同的环境来注册相应的bean呢？例如，我们想在程序运行的时候，将其切换到测试环境下。

第一种方式就是根据命令行参数来确定环境，我们在运行程序的时候可以添加相应的命令行参数。例如，如果我们现在的环境是测试环境，那么可以在运行程序的时候添加如下命令行参数。

> -Dspring.profiles.active=test

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643268819.png)

此时，点击`Run`按钮运行IOCTest_Profile类中的test01()方法，输出的结果信息如下所示。

> testDataSource

第二种方式就是通过写代码的方式来激活某种环境，其实主要是通过AnnotationConfigApplicationContext类的无参构造方法来实现，具体步骤如下：

1. 在bean上加@Profile注解，其value属性值为环境标识，可以自定义
2. 使用AnnotationConfigApplicationContext类的无参构造方法创建容器
3. 设置容器环境，其值为第1步设置的环境标识
4. 设置容器的配置类
5. 刷新容器

温馨提示：2、4、5步其实是AnnotationConfigApplicationContext类中带参构造方法的步骤，以上这几个步骤相当于是把其带参构造方法拆开，在其中插入一条语句设置容器环境，这些我们可以在AnnotationConfigApplicationContext类的带参构造方法中看到，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/27/1643268945.png)

好了，我们要开始正式编写代码来激活某种环境了。我们先在程序中调用AnnotationConfigApplicationContext类的无参构造方法来创建一个IOC容器，然后在容器进行初始化之前，为其设置相应的环境，接着再为容器设置主配置类，最后刷新一下容器。例如，我们将IOC容器设置为测试环境，如下所示。

```java
@Test
public void test02() {
	// 1. 使用无参构造器创建一个IOC容器
	AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext();
	// 2. 在我们容器还没启动创建其他bean之前，先设置需要激活的环境（可以设置激活多个环境哟）
	applicationContext.getEnvironment().setActiveProfiles("test");
	// 3. 注册主配置类
	applicationContext.register(MainConfigOfProfile.class);
	// 4. 启动刷新容器
	applicationContext.refresh();
	
	String[] namesForType = applicationContext.getBeanNamesForType(DataSource.class);
	for (String name : namesForType) {
		System.out.println(name);
	}
	
	// 关闭容器
	applicationContext.close();
}
```

此时，我们运行以上test02()方法，输出的结果信息如下所示。

> testDataSource

可以看到，IDEA控制台输出了testDataSource，说明我们成功将IOC容器的环境设置为了测试环境。

如果此时测试环境里面还有一些其他的组件，比如Yellow，

```java
@Profile("test")
@Bean
public Yellow yellow() {
	return new Yellow();
}
```

那么在测试环境被激活的情况下，测试环境下的所有bean都会被注册到IOC容器中。如果你要是不信的话，那么你可以试着修改一下IOCTest_Profile类中的test02()方法，即在其中获取Yellow组件并打印看看。

```java
@Test
public void test02() {	
	// 1. 使用无参构造器创建一个IOC容器
	AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext();
	// 2. 在我们容器还没启动创建其他bean之前，先设置需要激活的环境（可以设置激活多个环境哟）
	applicationContext.getEnvironment().setActiveProfiles("test");
	// 3. 注册主配置类
	applicationContext.register(MainConfigOfProfile.class);
	// 4. 启动刷新容器
	applicationContext.refresh();
	
	String[] namesForType = applicationContext.getBeanNamesForType(DataSource.class);
	for (String name : namesForType) {
		System.out.println(name);
	}
	
	Yellow yellow = applicationContext.getBean(Yellow.class);
	System.out.println(yellow);
	
	// 关闭容器
	applicationContext.close();
}

```

运行以上test02()方法，你将会看到如下所示的结果信息。

>testDataSource
>com.zsxfa.bean.Yellow@50378a4

这佐证了如果测试环境被激活，那么测试环境下的所有bean都会被注册到IOC容器中的这一结论。

@Profile注解不仅可以标注在方法上，也可以标注在配置类上。如果标注在配置类上，那么只有是在指定的环境的时候，整个配置类里面的所有配置才会生效。例如，我们在MainConfigOfProfile配置类上标注上`@Profile("dev")`注解，如下所示。

```java
@Profile("dev") // @Profile注解除了能写到bean上，还能写到类上
@PropertySource("classpath:/dbconfig.properties") // 加载外部的配置文件
@Configuration
public class MainConfigOfProfile implements EmbeddedValueResolverAware {
	/*********代码省略*********/
}
```

然后，我们来运行IOCTest_Profile类中的test02()方法，在运行该方法之前，记得要把获取Yellow组件并打印的两行代码给注释掉，要不然运行test02()方法之后，Eclipse控制台就会报错。这时，咱们再来运行test02()方法，会发现IDEA控制台中并未输出任何信息。

**这是因为我们在test02()方法中指定了当前的环境为测试环境，而MainConfigOfProfile配置类上标注的注解为`@Profile("dev")`，说明该配置类中的所有配置只有在开发环境下才会生效。所以，此时没有任何数据源注册到IOC容器中，自然IDEA控制台中就不会输出任何信息了。**

还记得在一开头就说过，**如果一个bean上没有使用@Profile注解进行标注，那么这个bean在任何环境下都会被注册到IOC容器中**吗？现在咱们就来验证这一点。

首先，我们要将MainConfigOfProfile配置类上标注的`@Profile("dev")`注解和yellow方法上的`@Profile("test")`给注释掉，好方便接下来的测试。

```java
//@Profile("dev") // @Profile注解除了能写到bean上，还能写到类上
@PropertySource("classpath:/dbconfig.properties") // 加载外部的配置文件
@Configuration
public class MainConfigOfProfile implements EmbeddedValueResolverAware {
	
	@Value("${db.user}")
	private String user;
	
	private StringValueResolver valueResolver;
	
	private String dirverClass;
	
//	@Profile("test")
	@Bean
	public Yellow yellow() {
		return new Yellow();
	}
	
	@Profile("test")
	@Bean("testDataSource")
	public DataSource dataSourceTest(@Value("${db.password}") String pwd) throws Exception {
		ComboPooledDataSource dataSource = new ComboPooledDataSource();
		dataSource.setUser(user);
		dataSource.setPassword(pwd);
		dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/test");
		dataSource.setDriverClass(dirverClass);
		return dataSource;
	}
	 
//	@Profile("default")
	@Profile("dev") // 定义了一个环境标识，只有当dev环境被激活以后，我们这个bean才能被注册进来
	@Bean("devDataSource")
	public DataSource dataSourceDev(@Value("${db.password}") String pwd) throws Exception {
		ComboPooledDataSource dataSource = new ComboPooledDataSource();
		dataSource.setUser(user);
		dataSource.setPassword(pwd);
		dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/ssm_crud");
		dataSource.setDriverClass(dirverClass);
		return dataSource;
	}
	
	@Profile("prod")
	@Bean("prodDataSource")
	public DataSource dataSourceProd(@Value("${db.password}") String pwd) throws Exception {
		ComboPooledDataSource dataSource = new ComboPooledDataSource();
		dataSource.setUser(user);
		dataSource.setPassword(pwd);
		dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/scw_0515");
		dataSource.setDriverClass(dirverClass);
		return dataSource;
	}

	@Override
	public void setEmbeddedValueResolver(StringValueResolver resolver) {
		this.valueResolver = resolver;
		dirverClass = valueResolver.resolveStringValue("${db.driverClass}");
	}
}
```

接着，修改一下IOCTest_Profile类中的test02()方法，即放开获取Yellow组件并打印的两行代码。

```java
@Test
public void test02() {
    // 1. 使用无参构造器创建一个IOC容器
    AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext();
    // 2. 在我们容器还没启动创建其他bean之前，先设置需要激活的环境（可以设置激活多个环境哟）
    applicationContext.getEnvironment().setActiveProfiles("test");
    // 3. 注册主配置类
    applicationContext.register(MainConfigOfProfile.class);
    // 4. 启动刷新容器
    applicationContext.refresh();

    String[] namesForType = applicationContext.getBeanNamesForType(DataSource.class);
    for (String name : namesForType) {
        System.out.println(name);
    }

    Yellow yellow = applicationContext.getBean(Yellow.class);
    System.out.println(yellow);

    // 关闭容器
    applicationContext.close();
}
```

可以看到，当前的环境指定为了开发环境，那么此时Yellow这个组件会被注册到IOC容器中吗？

紧接着，运行IOCTest_Profile类中的test02()方法，输出的结果信息如下所示。

> testDataSource
> com.zsxfa.bean.Yellow@50378a4

从以上输出结果中可以看到，Yellow组件上并没有使用@Profile注解进行标注，但是它在开发环境下被注册到IOC容器中了。

如果此时将当前的环境指定为生产环境，那么Yellow这个组件还会被注册到IOC容器中吗？

```java
@Test
public void test02() {
	// 1. 使用无参构造器创建一个IOC容器
	AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext();
	// 2. 在我们容器还没启动创建其他bean之前，先设置需要激活的环境（可以设置激活多个环境哟）
	applicationContext.getEnvironment().setActiveProfiles("prod");
	// 3. 注册主配置类
	applicationContext.register(MainConfigOfProfile.class);
	// 4. 启动刷新容器
	applicationContext.refresh();
	
	String[] namesForType = applicationContext.getBeanNamesForType(DataSource.class);
	for (String name : namesForType) {
		System.out.println(name);
	}
	
	Yellow yellow = applicationContext.getBean(Yellow.class);
	System.out.println(yellow);
	
	// 关闭容器
	applicationContext.close();
}
```

运行以上test02()方法，发现输出的结果信息如下所示。

> prodDataSource
> com.zsxfa.bean.Yellow@50378a4

这进一步说明了，虽然Yellow组件上并没有使用@Profile注解进行标注，但是它也在生产环境下被注册到IOC容器中了。

至此，**如果一个bean上没有使用@Profile注解进行标注，那么这个bean在任何环境下都会被注册到IOC容器中**这一结论就得到完美证明了。
























































































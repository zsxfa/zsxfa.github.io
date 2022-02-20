---
title: spring注解原理-IOC2 生命周期
date: 2022-01-26 14:10:32
tags: IOC
categories: Spring原理
---

通常意义上讲的bean的生命周期，指的是bean从创建到初始化，经过一系列的流程，最终销毁的过程。<!--more-->

[TOC]

# @Bean注解

## bean的生命周期

只不过，在Spring中，bean的生命周期是由Spring容器来管理的。在Spring中，我们可以自己来指定bean的初始化和销毁的方法。我们指定了bean的初始化和销毁方法之后，当容器在bean进行到当前生命周期的阶段时，会自动调用我们自定义的初始化和销毁方法。

### 定义初始化和销毁方法

首先，创建一个名称为Car的类，这个类的实现比较简单，如下所示。

```java
public class Car {
	public Car() {
		System.out.println("car constructor...");
	}
	public void init() {
		System.out.println("car ... init...");
	}
	public void destroy() {
		System.out.println("car ... destroy...");
	}
}
```

然后，我们将Car类对象通过注解的方式注册到Spring容器中，具体的做法就是新建一个MainConfigOfLifeCycle类作为Spring的配置类，将Car类对象通过MainConfigOfLifeCycle类注册到Spring容器中，MainConfigOfLifeCycle类的代码如下所示。

```java
@Configuration
public class MainConfigOfLifeCycle {
    @Bean
    public Car car() {
        return new Car();
    }
}
```

接着，我们就新建一个IOCTest_LifeCycle类来测试容器中的Car对象，该测试类的代码如下所示。

```java
public class IOCTest_LifeCycle {
    @Test
    public void test01() {
        // 1. 创建IOC容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfLifeCycle.class);
        System.out.println("容器创建完成");
    }
}
```

对于单实例bean对象来说，在Spring容器创建完成后，就会对单实例bean进行实例化。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643178155.png)

**总之，对于单实例bean来说，会在Spring容器启动的时候创建对象；对于多实例bean来说，会在每次获取bean的时候创建对象。**

#### **单实例bean的初始化和销毁方法。**

让Spring容器知道Car类中的init()方法是用来执行对象的初始化操作，而destroy()方法是用来执行对象的销毁操作

首先看看@Bean注解的源码：

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643178323.png)

可以发现使用@Bean注解的initMethod属性和destroyMethod属性来指定bean的初始化方法和销毁方法。

所以，我们得在MainConfigOfLifeCycle配置类的@Bean注解中指定initMethod属性和destroyMethod属性，如下所示。

```java
@Configuration
public class MainConfigOfLifeCycle {
	@Bean(initMethod="init", destroyMethod="destroy")
	public Car car() {
		return new Car();
	}
}
```

此时，我们再来运行IOCTest_LifeCycle类中的test01()方法，会发现输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643178416.png)

从输出结果中可以看出，在Spring容器中，先是调用了Car类的构造方法来创建Car对象，接下来便是调用了Car对象的init()方法来进行初始化。

**bean的销毁方法是在容器关闭的时候被调用的。**所以我们在IOCTest_LifeCycle类中的test01()方法中，添加关闭容器的代码

```java
public class IOCTest_LifeCycle {
    @Test
    public void test01() {
        // 1. 创建IOC容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfLifeCycle.class);
        System.out.println("容器创建完成");

        // 关闭容器
        applicationContext.close();
    }
}
```

此时，我们再来运行IOCTest_LifeCycle类中的test01()方法，会发现输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643178538.png)

#### 多实例bean的初始化和销毁方法。

首先，我们在MainConfigOfLifeCycle配置类中的car()方法上通过@Scope注解将Car对象设置成多实例bean，如下所示。

```java
@Configuration
public class MainConfigOfLifeCycle {
    @Scope("prototype")
    @Bean(initMethod="init", destroyMethod="destroy")
    public Car car() {
        return new Car();
    }
}
```

然后，我们修改一下IOCTest_LifeCycle类中的test01()方法，将关闭容器的那行代码给注释掉，如下所示。

```java
@Test
public void test01() {
	// 1. 创建IOC容器
	AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfLifeCycle.class);
	System.out.println("容器创建完成");
	
	// 关闭容器
	// applicationContext.close();
}
```

接着，运行以上test01()方法，发现输出的结果信息如下所示。

> 容器创建完成

可以看到，当我们将Car对象设置成多实例bean，并且没有获取bean实例对象时，Spring容器并没有执行bean的构造方法、初始化方法和销毁方法。

说到这，我们就在IOCTest_LifeCycle类中的test01()方法里面添加一行获取Car对象的代码，如下所示。

```java
@Test
public void test01() {
	// 1. 创建IOC容器
	AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfLifeCycle.class);
	System.out.println("容器创建完成");
	
	applicationContext.getBean("car"); // 多实例bean在获取的时候才创建对象
	
	// 关闭容器
	// applicationContext.close();
}
```

再次运行以上test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643180138.png)

可以看到，此时，结果信息中输出了构造方法和初始化方法中的信息。

当我们在获取多实例bean对象的时候，会创建对象并进行初始化，但是销毁方法是在什么时候被调用呢？是在容器关闭的时候吗？我们可以将IOCTest_LifeCycle类中的test01()方法里面的那行关闭容器的代码放开来进行验证

```java
@Test
public void test01() {
    // 1. 创建IOC容器
    AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfLifeCycle.class);
    System.out.println("容器创建完成");

    applicationContext.getBean("car"); // 多实例bean在获取的时候才创建对象

    // 关闭容器
    applicationContext.close();
}
```

结果发现**多实例的bean在容器关闭的时候是不进行销毁的**，也就是说你每次获取时，IOC容器帮你创建出对象交还给你，至于要什么时候销毁这是你自己的事，Spring容器压根就不会再管理这些多实例的bean了。

### 指定初始化和销毁方法的使用场景

一个典型的使用场景就是对于数据源的管理。例如，在配置数据源时，在初始化的时候，会对很多的数据源的属性进行赋值操作；在销毁的时候，我们需要对数据源的连接等信息进行关闭和清理。这个时候，我们就可以在自定义的初始化和销毁方法中来做这些事情了！

### 初始化和销毁方法调用的时机

- bean对象的初始化方法调用的时机：对象创建完成，如果对象中存在一些属性，并且这些属性也都赋好值之后，那么就会调用bean的初始化方法。对于单实例bean来说，在Spring容器创建完成后，Spring容器会自动调用bean的初始化方法；对于多实例bean来说，在每次获取bean对象的时候，调用bean的初始化方法。
- bean对象的销毁方法调用的时机：对于单实例bean来说，在容器关闭的时候，会调用bean的销毁方法；对于多实例bean来说，Spring容器不会管理这个bean，也就不会自动调用这个bean的销毁方法了。不过，小伙伴们可以手动调用多实例bean的销毁方法。

# InitializingBean和DisposableBean管理bean的生命周期

## InitializingBean接口

Spring中提供了一个InitializingBean接口，该接口为bean提供了属性初始化后的处理方法，它只包括afterPropertiesSet方法，凡是继承该接口的类，在bean的属性初始化后都会执行该方法。InitializingBean接口的源码如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643180635.png)

根据InitializingBean接口中提供的afterPropertiesSet()方法的名字不难推断出，afterPropertiesSet()方法是在属性赋好值之后调用的。

下面我们来分析下afterPropertiesSet()方法的调用时机。

### 何时调用InitializingBean接口？

我们定位到Spring中的org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory这个类里面的invokeInitMethods()方法中，来查看Spring加载bean的方法。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643181243.png)

分析上述代码后，我们可以初步得出如下信息：

1. Spring为bean提供了两种初始化的方式，实现InitializingBean接口（也就是要实现该接口中的afterPropertiesSet方法），或者在配置文件或@Bean注解中通过init-method来指定，两种方式可以同时使用。
2. 实现InitializingBean接口是直接调用afterPropertiesSet()方法，与通过反射调用init-method指定的方法相比，效率相对来说要高点。但是init-method方式消除了对Spring的依赖。
3. 如果调用afterPropertiesSet方法时出错，那么就不会调用init-method指定的方法了。

也就是说Spring为bean提供了两种初始化的方式，第一种方式是实现InitializingBean接口（也就是要实现该接口中的afterPropertiesSet方法），第二种方式是在配置文件或@Bean注解中通过init-method来指定，**这两种方式可以同时使用，同时使用先调用afterPropertiesSet方法，后执行init-method指定的方法。**

## DisposableBean接口

实现org.springframework.beans.factory.DisposableBean接口的bean在销毁前，Spring将会调用DisposableBean接口的destroy()方法。也就是说我们可以实现DisposableBean这个接口来定义咱们这个销毁的逻辑。

我们先来看下DisposableBean接口的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643181425.png)

可以看到，在DisposableBean接口中只定义了一个destroy()方法。

在bean生命周期结束前调用destroy()方法做一些收尾工作，亦可以使用destroy-method。**前者与Spring耦合高，使用类型强转.方法名()，效率高；后者耦合低，使用反射，效率相对来说较低。**

### DisposableBean接口注意事项

多实例bean的生命周期不归Spring容器来管理，这里的DisposableBean接口中的方法是由Spring容器来调用的，所以如果一个多实例bean实现了DisposableBean接口是没有啥意义的，因为相应的方法根本不会被调用，当然了，在XML配置文件中指定了destroy方法，也是没有任何意义的。所以，在多实例bean情况下，Spring是不会自动调用bean的销毁方法的。

## 单实例bean案例

首先，创建一个Cat的类来实现InitializingBean和DisposableBean这俩接口，代码如下所示，注意该Cat类上标注了一个@Component注解。

```java
@Component
public class Cat implements InitializingBean, DisposableBean {

    public Cat() {
        System.out.println("cat constructor...");
    }

    /**
     * 会在容器关闭的时候进行调用
     */
    @Override
    public void destroy() throws Exception {
        // TODO Auto-generated method stub
        System.out.println("cat destroy...");
    }

    /**
     * 会在bean创建完成，并且属性都赋好值以后进行调用
     */
    @Override
    public void afterPropertiesSet() throws Exception {
        // TODO Auto-generated method stub
        System.out.println("cat afterPropertiesSet...");
    }
}
```

然后，在MainConfigOfLifeCycle配置类中通过包扫描的方式将以上类注入到Spring容器中。

```java
@ComponentScan("com.zsxfa.bean")
@Configuration
public class MainConfigOfLifeCycle {
    @Scope("prototype")
    @Bean(initMethod="init", destroyMethod="destroy")
    public Car car() {
        return new Car();
    }
}
```

接着，运行IOCTest_LifeCycle类中的test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643182105.png)

从输出的结果信息中可以看出，单实例bean情况下，IOC容器创建完成后，会自动调用bean的初始化方法；而在容器销毁前，会自动调用bean的销毁方法。

## 多实例bean案例

多实例bean的案例代码基本与单实例bean的案例代码相同，只不过是在Cat类上添加了一个`@Scope("prototype")`注解

```java
@Scope("prototype")
@Component
public class Cat implements InitializingBean, DisposableBean {

    public Cat() {
        System.out.println("cat constructor...");
    }

    /**
     * 会在容器关闭的时候进行调用
     */
    @Override
    public void destroy() throws Exception {
        // TODO Auto-generated method stub
        System.out.println("cat destroy...");
    }

    /**
     * 会在bean创建完成，并且属性都赋好值以后进行调用
     */
    @Override
    public void afterPropertiesSet() throws Exception {
        // TODO Auto-generated method stub
        System.out.println("cat afterPropertiesSet...");
    }
}
```

然后，我们在IOCTest_LifeCycle类中新增一个test02()方法来进行测试，如下所示。

```java
@Test
public void test02() {
    // 1. 创建IOC容器
    AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfLifeCycle.class);
    System.out.println("容器创建完成");
    System.out.println("--------");

    // 调用时创建对象
    Object bean = applicationContext.getBean("cat");
    System.out.println("--------");

    // 调用时创建对象
    Object bean1 = applicationContext.getBean("cat");
    System.out.println("--------");

    // 关闭容器
    applicationContext.close();
}
```

接着，运行IOCTest_LifeCycle类中的test02()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643182450.png)

从输出的结果信息中可以看出，在多实例bean情况下，Spring不会自动调用bean的销毁方法。

# @PostConstruct注解和@PreDestroy注解

在JDK中还提供了两个注解能够在bean创建完成并且属性赋值完成之后执行一些初始化工作和在容器销毁bean之前通知我们进行一些清理工作

## @PostConstruct注解

@PostConstruct注解好多人以为是Spring提供的，其实它是Java自己的注解，是JSR-250规范里面定义的一个注解。我们来看下@PostConstruct注解的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643182892.png)

**从源码可以看出，@PostConstruct注解是Java中的注解，并不是Spring提供的注解。**

@PostConstruct注解被用来修饰一个非静态的void()方法。被@PostConstruct注解修饰的方法会在服务器加载Servlet的时候运行，并且只会被服务器执行一次。被@PostConstruct注解修饰的方法通常在构造函数之后，init()方法之前执行。

通常我们是会在Spring框架中使用到@PostConstruct注解的，该注解的方法在整个bean初始化中的执行顺序如下：

> Constructor（构造方法）→@Autowired（依赖注入）→@PostConstruct（注释的方法）

## @PreDestroy注解

@PreDestroy注解同样是Java提供的，它也是JSR-250规范里面定义的一个注解。看下它的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643183049.png)

被@PreDestroy注解修饰的方法会在服务器卸载Servlet的时候运行，并且只会被服务器调用一次，类似于Servlet的destroy()方法。被@PreDestroy注解修饰的方法会在destroy()方法之**前**，Servlet被彻底卸载之前执行。执行顺序如下所示：

> 调用destroy()方法→@PreDestroy→destroy()方法→bean销毁

## 小结

@PostConstruct和@PreDestroy是Java规范JSR-250引入的注解，定义了对象的创建和销毁工作，同一期规范中还有@Resource注解，Spring也支持了这些注解。

## 案例

对@PostConstruct注解和@PreDestroy注解有了简单的了解之后，接下来，我们就写一个简单的程序来加深对这两个注解的理解。

首先，我们创建一个Dog类，如下所示，注意在该类上标注了一个@Component注解。

```java
@Component
public class Dog {
    public Dog() {
        System.out.println("dog constructor...");
    }
    
    public void init() {
        System.out.println("dog ... init...");
    }
    
    public void destroy() {
        System.out.println("dog ... destroy...");
    }
    
    // 在对象创建完成并且属性赋值完成之后调用
    @PostConstruct
    public void init() {
        System.out.println("dog...@PostConstruct...");
    }

    // 在容器销毁（移除）对象之前调用
    @PreDestroy
    public void destory() {
        System.out.println("dog...@PreDestroy...");
    }
}
```

可以看到，在以上Dog类中，我们提供了构造方法、init()方法以及destroy()方法，并且还使用了@PostConstruct注解和@PreDestroy注解来分别标注init()方法和destroy()方法。

然后，在MainConfigOfLifeCycle配置类中通过包扫描的方式将以上类注入到Spring容器中。

```java
@ComponentScan("com.zsxfa.bean")
@Configuration
public class MainConfigOfLifeCycle {
    @Scope("prototype")
    @Bean(initMethod="init", destroyMethod="destroy")
    public Car car() {
        return new Car();
    }
    
    @Bean(initMethod="init", destroyMethod="destroy")
    public Dog dog() {
        return new Dog();
    }
}
```

接着，运行IOCTest_LifeCycle类中的test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643184345.png)

从输出的结果信息中可以看出，被@PostConstruct注解修饰的方法是在bean创建完成并且属性赋值完成之后才执行的，而被@PreDestroy注解修饰的方法是在容器销毁bean之前执行的，通常是进行一些清理工作。

# BeanPostProcessor后置处理器

首先，我们来看下BeanPostProcessor的源码

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643185429.png)

从源码可以看出，BeanPostProcessor是一个接口，其中有两个方法，即postProcessBeforeInitialization和postProcessAfterInitialization这两个方法，这两个方法分别是在Spring容器中的bean初始化前后执行，所以Spring容器中的每一个bean对象初始化前后，都会执行BeanPostProcessor接口的实现类中的这两个方法。

也就是说，**postProcessBeforeInitialization方法会在bean实例化和属性设置之后，自定义初始化方法之前被调用，而postProcessAfterInitialization方法会在自定义初始化方法之后被调用。当容器中存在多个BeanPostProcessor的实现类时，会按照它们在容器中注册的顺序执行。对于自定义的BeanPostProcessor实现类，还可以让其实现Ordered接口自定义排序。**

因此我们可以在每个bean对象初始化前后，加上自己的逻辑。实现方式是自定义一个BeanPostProcessor接口的实现类，例如MyBeanPostProcessor，然后在该类的postProcessBeforeInitialization和postProcessAfterInitialization这俩方法中写上自己的逻辑。

## BeanPostProcessor后置处理器实例

我们创建一个MyBeanPostProcessor类，实现BeanPostProcessor接口，如下所示。

```java
@Component // 将后置处理器加入到容器中，这样的话，Spring就能让它工作了
public class MyBeanPostProcessor implements BeanPostProcessor {

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        // TODO Auto-generated method stub
        System.out.println("postProcessBeforeInitialization..." + beanName + "=>" + bean);
        return bean;
    }
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        // TODO Auto-generated method stub
        System.out.println("postProcessAfterInitialization..." + beanName + "=>" + bean);
        return bean;
    }
}
```

接下来，我们应该是要编写测试用例来进行测试了。不过，在这之前，咱们得做几处改动，第一处改动是将MainConfigOfLifeCycle配置类中的car()方法上的`@Scope("prototype")`注解给注释掉，因为咱们之前做测试的时候，是将Car对象设置成多实例bean了。

```java
@ComponentScan("com.zsxfa.bean")
@Configuration
public class MainConfigOfLifeCycle {

//	@Scope("prototype")
	@Bean(initMethod="init", destroyMethod="destroy")
	public Car car() {
		return new Car();
	}
}
```

第二处改动是将Cat类上添加的`@Scope("prototype")`注解给注释掉，因为之前做测试的时候，也是将Cat对象设置成多实例bean了。

```java
//@Scope("prototype")
@Component
public class Cat implements InitializingBean, DisposableBean {

    public Cat() {
        System.out.println("cat constructor...");
    }

    /**
     * 会在容器关闭的时候进行调用
     */
    @Override
    public void destroy() throws Exception {
        // TODO Auto-generated method stub
        System.out.println("cat destroy...");
    }

    /**
     * 会在bean创建完成，并且属性都赋好值以后进行调用
     */
    @Override
    public void afterPropertiesSet() throws Exception {
        // TODO Auto-generated method stub
        System.out.println("cat afterPropertiesSet...");
    }
}
```

好了，现在咱们就可以编写测试用例来进行测试了。可喜的是，我们也不用再编写一个测试用例了，直接运行IOCTest_LifeCycle类中的test01()方法就行，该方法的代码如下所示。

```java
@Test
public void test01() {
    // 1. 创建IOC容器
    AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfLifeCycle.class);
    System.out.println("容器创建完成");
    
    // 关闭容器
    applicationContext.close();
}
```

此时，运行IOCTest_LifeCycle类中的test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643186667.png)

当然了，也可以让我们自己写的MyBeanPostProcessor类来实现Ordered接口自定义排序，如下所示。

```java
@Component // 将后置处理器加入到容器中，这样的话，Spring就能让它工作了
public class MyBeanPostProcessor implements BeanPostProcessor, Ordered{

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        // TODO Auto-generated method stub
        System.out.println("postProcessBeforeInitialization..." + beanName + "=>" + bean);
        return bean;
    }
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        // TODO Auto-generated method stub
        System.out.println("postProcessAfterInitialization..." + beanName + "=>" + bean);
        return bean;
    }
    @Override
    public int getOrder() {
        // TODO Auto-generated method stub
        return 3;
    }
}
```

## BeanPostProcessor后置处理器作用

后置处理器可用于bean对象初始化前后进行逻辑增强。Spring提供了BeanPostProcessor接口的很多实现类，例如AutowiredAnnotationBeanPostProcessor用于@Autowired注解的实现，AnnotationAwareAspectJAutoProxyCreator用于Spring AOP的动态代理等等。

## BeanPostProcessor的执行流程

我们知道BeanPostProcessor的postProcessBeforeInitialization()方法是在bean的初始化之前被调用；而postProcessAfterInitialization()方法是在bean初始化的之后被调用。并且**bean的初始化和销毁方法我们可以通过如下方式进行指定: **

（一）通过@Bean指定init-method和destroy-method

```java
@Bean(initMethod="init", destroyMethod="destroy")
public Car car() {
    return new Car();
}
```

（二）通过让bean实现InitializingBean和DisposableBean这俩接口

```java
@Component
public class Cat implements InitializingBean, DisposableBean {
    public Cat() {
        System.out.println("cat constructor...");
    }
    //会在容器关闭的时候进行调用
    @Override
    public void destroy() throws Exception {
        // TODO Auto-generated method stub
        System.out.println("cat destroy...");
    }
    // 会在bean创建完成，并且属性都赋好值以后进行调用
    @Override
    public void afterPropertiesSet() throws Exception {
        // TODO Auto-generated method stub
        System.out.println("cat afterPropertiesSet...");
    }
}
```

（三）使用JSR-250规范里面定义的@PostConstruct和@PreDestroy这俩注解
@PostConstruct：在bean创建完成并且属性赋值完成之后，来执行初始化方法
@PreDestroy：在容器销毁bean之前通知我们进行清理工作

```java
@Component
public class Dog {

    public Dog() {
        System.out.println("dog constructor...");
    }
    // 在对象创建完成并且属性赋值完成之后调用
    @PostConstruct
    public void init() {
        System.out.println("dog...@PostConstruct...");
    }
    // 在容器销毁（移除）对象之前调用
    @PreDestroy
    public void destory() {
        System.out.println("dog...@PreDestroy...");
    }
}
```

（四）通过让bean实现BeanPostProcessor接口

```java
@Component // 将后置处理器加入到容器中，这样的话，Spring就能让它工作了
public class MyBeanPostProcessor implements BeanPostProcessor, Ordered {

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        // TODO Auto-generated method stub
        System.out.println("postProcessBeforeInitialization..." + beanName + "=>" + bean);
        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        // TODO Auto-generated method stub
        System.out.println("postProcessAfterInitialization..." + beanName + "=>" + bean);
        return bean;
    }

    @Override
    public int getOrder() {
        // TODO Auto-generated method stub
        return 3;
    }
}
```

通过以上这四种方式，我们就可以对bean的整个生命周期进行控制：

- bean的实例化：调用bean的构造方法，我们可以在bean的无参构造方法中执行相应的逻辑。
- bean的初始化：在初始化时，可以通过BeanPostProcessor的postProcessBeforeInitialization()方法和postProcessAfterInitialization()方法进行拦截，执行自定义的逻辑；通过@PostConstruct注解、InitializingBean和init-method来指定bean初始化前后执行的方法，在该方法中咱们可以执行自定义的逻辑。
- bean的销毁：可以通过@PreDestroy注解、DisposableBean和destroy-method来指定bean在销毁前执行的方法，在该方法中咱们可以执行自定义的逻辑。

所以，通过上述四种方式，我们可以控制Spring中bean的整个生命周期。

## BeanPostProcessor源码解析

如果想深刻理解BeanPostProcessor的工作原理，那么就不得不看下相关的源码，我们可以在MyBeanPostProcessor类的postProcessBeforeInitialization()方法和postProcessAfterInitialization()方法这两处打上断点来进行调试，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643188895.png)

随后，我们以Debug的方式来运行IOCTest_LifeCycle类中的test01()方法，运行后的效果如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643189540.png)

第一步，我们在IDEA的方法调用栈中，找到IOCTest_LifeCycle类的test01()方法并单击，此时Eclipse的主界面会定位到IOCTest_LifeCycle类的test01()方法中，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643189570.png)

第二步，通过IDEA的方法调用栈继续分析，单击IOCTest_LifeCycle类的test01()方法上面的那个方法，这时会进入AnnotationConfigApplicationContext类的构造方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643189496.png)

可以看到，在AnnotationConfigApplicationContext类的构造方法中会调用refresh()方法。

第三步，我们继续跟进方法调用栈，如下所示，可以看到，方法的执行定位到AbstractApplicationContext类的refresh()方法中的如下那行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643189470.png)

上面这行代码的作用就是初始化所有的（非[懒加载](https://so.csdn.net/so/search?q=懒加载&spm=1001.2101.3001.7020)的）单实例bean对象。

第四步，我们继续跟进方法调用栈，如下所示，可以看到，方法的执行定位到AbstractApplicationContext类的finishBeanFactoryInitialization()方法中的如下那行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643189702.png)

第五步，我们继续跟进方法调用栈，如下所示，可以看到，方法的执行定位到DefaultListableBeanFactory类的preInstantiateSingletons()方法的最后一个else分支调用的getBean()方法上。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643189767.png)

第六步，继续跟进方法调用栈，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643189809.png)

此时方法定位到AbstractBeanFactory类的getBean()方法中了，在getBean()方法中，又调用了doGetBean()方法。

第七步，继续跟进方法调用栈，如下所示，此时，方法的执行定位到AbstractBeanFactory类的doGetBean()方法中的如下那行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643189865.png)

可以看到，在Spring内部是通过getSingleton()方法来获取单实例bean的。

第八步，继续跟进方法调用栈，如下所示，此时，方法定位到DefaultSingletonBeanRegistry类的getSingleton()方法中的如下那行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643189916.png)

可以看到，在getSingleton()方法里面又调用了getObject()方法来获取单实例bean。

第九步，继续跟进方法调用栈，如下所示，此时，方法定位到AbstractBeanFactory类的doGetBean()方法中的如下那行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643189966.png)

也就是说，当第一次获取单实例bean时，由于单实例bean还未创建，那么Spring会调用createBean()方法来创建单实例bean。

第十步，继续跟进方法调用栈，如下所示，可以看到，方法的执行定位到AbstractAutowireCapableBeanFactory类的createBean()方法中的如下那行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643190003.png)

可以看到，Spring中创建单实例bean调用的是doCreateBean()方法。

第十一步，继续跟进方法调用栈，如下所示，此时，方法的执行已经定位到AbstractAutowireCapableBeanFactory类的doCreateBean()方法中的如下那行代码处了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643190056.png)

在initializeBean()方法里面会调用一系列的后置处理器。

第十二步，继续跟进方法调用栈，如下所示，此时，方法的执行定位到AbstractAutowireCapableBeanFactory类的initializeBean()方法中的如下那行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643190092.png)

小伙伴们需要重点留意一下这个applyBeanPostProcessorsBeforeInitialization()方法。

回过头来我们再来看看AbstractAutowireCapableBeanFactory类的doCreateBean()方法中的如下这行代码。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643190422.png)

在以上initializeBean()方法中调用了后置处理器的逻辑

在AbstractAutowireCapableBeanFactory类的doCreateBean()方法中，调用initializeBean()方法之前，还调用了一个populateBean()方法，我也在上图中标注出来了。

**populateBean**()方法同样是AbstractAutowireCapableBeanFactory类中的方法，它里面的代码比较多，但是逻辑非常简单，populateBean()方法做的工作就是为bean的属性赋值。也就是说，在Spring中会先调用populateBean()方法为bean的属性赋好值，然后再调用initializeBean()方法。

接下来，我们好好分析下initializeBean()方法，为了方便，我将Spring中AbstractAutowireCapableBeanFactory类的initializeBean()方法的代码特意提取出来了，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643190660.png)

在initializeBean()方法中，调用了invokeInitMethods()方法，代码行如下所示。

invokeInitMethods()方法的作用就是执行初始化方法，这些初始化方法包括我们之前讲的：**在XML配置文件的标签中使用init-method属性指定的初始化方法；在@Bean注解中使用initMehod属性指定的方法；使用@PostConstruct注解标注的方法；实现InitializingBean接口的方法等。**

- **在调用invokeInitMethods()方法之前，Spring调用了applyBeanPostProcessorsBeforeInitialization()这个方法**

- **在调用invokeInitMethods()方法之后，Spring又调用了applyBeanPostProcessorsAfterInitialization()这个方法**

这里，我们先来看看applyBeanPostProcessorsBeforeInitialization()方法中具体执行了哪些逻辑，该方法位于AbstractAutowireCapableBeanFactory类中，源码如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643190984.png)

可以看到，在applyBeanPostProcessorsBeforeInitialization()方法中，会遍历所有BeanPostProcessor对象，然后依次执行所有BeanPostProcessor对象的postProcessBeforeInitialization()方法，一旦BeanPostProcessor对象的postProcessBeforeInitialization()方法返回null以后，则后面的BeanPostProcessor对象便不再执行了，而是直接退出for循环。这些都是我们看源码看到的。

看Spring源码，我们还看到了一个细节，**在Spring中调用initializeBean()方法之前，还调用了populateBean()方法来为bean的属性赋值**

经过上面的一系列的跟踪源码分析，我们可以将关键代码的调用过程使用如下伪代码表述出来。

```java
populateBean(beanName, mbd, instanceWrapper); // 给bean进行属性赋值
initializeBean(beanName, exposedObject, mbd)
{
	applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);
	invokeInitMethods(beanName, wrappedBean, mbd); // 执行自定义初始化
	applyBeanPostProcessorsAfterInitialization(wrappedBean, beanName);
}
```

也就是说，在Spring中，调用initializeBean()方法之前，调用了populateBean()方法为bean的属性赋值，为bean的属性赋好值之后，再调用initializeBean()方法进行初始化。

在initializeBean()中，调用自定义的初始化方法（即invokeInitMethods()）之前，调用了applyBeanPostProcessorsBeforeInitialization()方法，而在调用自定义的初始化方法之后，又调用了applyBeanPostProcessorsAfterInitialization()方法。至此，整个bean的初始化过程就这样结束了。

## BeanPostProcessor在Spring底层的使用

我们先来看下BeanPostProcessor接口的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643191991.png)

可以看到，在BeanPostProcessor接口中，提供了两个方法：postProcessBeforeInitialization()方法和postProcessAfterInitialization()方法。postProcessBeforeInitialization()方法会在bean初始化之前调用，postProcessAfterInitialization()方法会在bean初始化之后调用。接下来，我们就来分析下BeanPostProcessor接口在Spring中的实现。

**注意：这里，列举了几个BeanPostProcessor接口在Spring中的实现类**

### ApplicationContextAwareProcessor类

org.springframework.context.support.ApplicationContextAwareProcessor是BeanPostProcessor接口的一个实现类，这个类的作用是可以向组件中注入IOC容器，大致的源码如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643192605.png)

要想使用ApplicationContextAwareProcessor类向组件中注入IOC容器，我们就不得不提Spring中的另一个接口了，即ApplicationContextAware。如果需要向组件中注入IOC容器，那么可以让组件实现ApplicationContextAware接口。

例如，我们创建一个Dog类，使其实现ApplicationContextAware接口，此时，我们需要实现ApplicationContextAware接口中的setApplicationContext()方法，在setApplicationContext()方法中有一个ApplicationContext类型的参数，这个就是IOC容器对象，我们可以在Dog类中定义一个ApplicationContext类型的成员变量，然后在setApplicationContext()方法中为这个成员变量赋值，此时就可以在Dog类中的其他方法中使用ApplicationContext对象了，如下所示。

```java
@Component
public class Dog implements ApplicationContextAware {

    private ApplicationContext applicationContext;

    public Dog() {System.out.println("dog constructor...");}
    public void init() {System.out.println("dog ... init...");}
    public void destroy() {System.out.println("dog ... destroy...");}
    // 在对象创建完成并且属性赋值完成之后调用
    @PostConstruct
    public void init1() {System.out.println("dog...@PostConstruct...");}
    // 在容器销毁（移除）对象之前调用
    @PreDestroy
    public void destory2() {System.out.println("dog...@PreDestroy...");}
    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException { // 在这儿打个断点调试一下
        // TODO Auto-generated method stub
        this.applicationContext = applicationContext;
    }
}
```

接下来，我们就深入分析下ApplicationContextAwareProcessor类。

我们先来看下ApplicationContextAwareProcessor类中对于postProcessBeforeInitialization()方法的实现，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643192967.png)

在bean初始化之前，首先对当前bean的类型进行判断，如果当前bean的类型不是EnvironmentAware，不是EmbeddedValueResolverAware，不是ResourceLoaderAware，不是ApplicationEventPublisherAware，不是MessageSourceAware，也不是ApplicationContextAware，那么直接返回bean。如果是上面类型中的一种类型，那么最终会调用invokeAwareInterfaces()方法，并将bean传递给该方法。

我们继续看invokeAwareInterfaces()方法的源码

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643193120.png)

可以看到invokeAwareInterfaces()方法的源码比较简单，就是判断当前bean属于哪种接口类型，然后将bean强转为哪种接口类型的对象，接着调用接口中的方法，将相应的参数传递到接口的方法中。这里，我们在创建Dog类时，实现的是ApplicationContextAware接口，所以，在invokeAwareInterfaces()方法中，会执行如下的逻辑代码。

```java
if (bean instanceof ApplicationContextAware) {
    ((ApplicationContextAware) bean).setApplicationContext(this.applicationContext);
}
```

我们可以看到，此时会将this.applicationContext传递到ApplicationContextAware接口的setApplicationContext()方法中。所以，我们在Dog类的setApplicationContext()方法中就可以直接接收到ApplicationContext对象了。

### BeanValidationPostProcessor类

org.springframework.validation.beanvalidation.BeanValidationPostProcessor类主要是用来为bean进行校验操作的，当我们创建bean，并为bean赋值后，我们可以通过BeanValidationPostProcessor类为bean进行校验操作。BeanValidationPostProcessor类的源码如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643198240.png)

这里，我们也来看看postProcessBeforeInitialization()方法和postProcessAfterInitialization()方法的实现，如下所示。

可以看到，在postProcessBeforeInitialization()方法和postProcessAfterInitialization()方法中的主要逻辑都是调用doValidate()方法对bean进行校验，只不过在这两个方法中都会对afterInitialization这个boolean类型的成员变量进行判断，若afterInitialization的值为false，则在postProcessBeforeInitialization()方法中调用doValidate()方法对bean进行校验；若afterInitialization的值为true，则在postProcessAfterInitialization()方法中调用doValidate()方法对bean进行校验。

### InitDestroyAnnotationBeanPostProcessor类

org.springframework.beans.factory.annotation.InitDestroyAnnotationBeanPostProcessor类主要用来处理@PostConstruct注解和@PreDestroy注解。

例如，我们之前创建的Dog类中就使用了@PostConstruct注解和@PreDestroy注解，如下所示。

```java
@Component
public class Dog implements ApplicationContextAware {

    private ApplicationContext applicationContext;

    public Dog() {
        System.out.println("dog constructor...");
    }

    public void init() {
        System.out.println("dog ... init...");
    }
    public void destroy() {
        System.out.println("dog ... destroy...");
    }

    // 在对象创建完成并且属性赋值完成之后调用
    @PostConstruct
    public void init1() {
        System.out.println("dog...@PostConstruct...");
    }

    // 在容器销毁（移除）对象之前调用
    @PreDestroy
    public void destory2() {
        System.out.println("dog...@PreDestroy...");
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException { // 在这儿打个断点调试一下
        // TODO Auto-generated method stub
        this.applicationContext = applicationContext;
    }
}
```

那么，在Dog类中使用了@PostConstruct注解和@PreDestroy注解来标注方法，Spring怎么就知道什么时候执行@PostConstruct注解标注的方法，什么时候执行@PreDestroy注解标注的方法呢？这就要归功于InitDestroyAnnotationBeanPostProcessor类了。

接下来，我们也通过Debug的方式来跟进下代码的执行流程。首先，在Dog类的init1()方法上打上一个断点，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643198510.png)

然后，我们以Debug的方式运行IOCTest_LifeCycle类中的test01()方法，效果如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643198636.png)

我们还是带着问题来分析，Spring怎么就能定位到使用@PostConstruct注解标注的方法呢？通过分析方法的调用栈，我们发现在进入使用@PostConstruct注解标注的方法之前，Spring调用了InitDestroyAnnotationBeanPostProcessor类的postProcessBeforeInitialization()方法，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643198907.png)

在InitDestroyAnnotationBeanPostProcessor类的postProcessBeforeInitialization()方法中，首先会找到bean中有关生命周期的注解，比如@PostConstruct注解等，找到这些注解之后，则将这些信息赋值给LifecycleMetadata类型的变量metadata，之后调用metadata的invokeInitMethods()方法，通过反射来调用标注了@PostConstruct注解的方法。这就是为什么标注了@PostConstruct注解的方法会被Spring执行的原因。

### AutowiredAnnotationBeanPostProcessor类

org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor类主要是用于处理标注了@Autowired注解的变量或方法。

Spring为何能够自动处理标注了@Autowired注解的变量或方法，不再详细分析了。可以写一个测试方法并通过方法调用堆栈来分析AutowiredAnnotationBeanPostProcessor类的源码，从而找到自己想要的答案。





















